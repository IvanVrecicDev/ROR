class HTMLToPDFGenerator

  def self.generate_ticket(html, attendance) # Generation QR code 
    qr_generator = RQRCode::QRCode.new(attendance.token, :size => 4)
      qr_encoded = qr_generator.to_img.resize(300, 300).to_data_url
      doc = Nokogiri::XML(html)
      doc.css("text").each do |node|
        qr = /\{%\sqr\s*(\d*)\s*%\}/i.match(node.content)
        if qr
          transform = node['transform']
          size = qr[1]
          node.replace(%Q[<image overflow="visible" width="#{size}" height="#{size}" transform="#{transform}">])
        end
      end
      html_data = doc.to_xml

    rendered_html = render_html_template(svg, { "attendee" => AttendanceDrop.new(attendance), # recognition html template
                                              "event" => EventDrop.new(attendance.event), 
                                              "account" => attendance.event.account, 
                                              "site" => attendance.event.account.site,
                                              "qr" => html_data})

    pdf = WickedPdf.new.pdf_from_string(rendered_html.gsub(/https/, "http")) # convert to pdf data
  end

  def self.render_html_template(html, data) # rendering html template
    template = Liquid::Template.parse(html)
    template.render(data, filters: [MitinguFilters], registers: { account: data["account"]})
  end

  def self.generate_file(html, type = :pdf) # generate pdf file for svg 
    data = IO.popen(['rsvg-convert','-f', type.to_s], 'r+') do |f|
      f.puts(html)
      f.close_write
      f.read
    end
    return data
  end

end