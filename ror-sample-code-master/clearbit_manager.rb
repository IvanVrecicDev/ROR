module ClearbitManager

  PROSPECTOR_COUNT = 20

  COLLEGE_RECRUITER_TITLES = [
      'university recruiter',
      'university relations',
      'campus recruiter',
      'college recruiter',
      'head of graduate recruitment',
      'graduate recruiter'
  ]

  OTHER_RECRUITER_TITLES = [
      'recruiter',
      'senior recruiter',
      'resourcer',
      'sourcer'
  ]

  FOUNDER_TITLES = [
      "Co-founder",
      "Founder",
      "CEO"
  ]

  def get_companies_by_industry(industry, result_count=100, sort_by='employees')
    pages = (result_count / 10.0).ceil
    results = []
    (1..pages).each do |page|
      page_results = Clearbit::Discovery.search({
                                                    query: [{industry: industry}, {country: 'US'}],
                                                    sort: sort_by,
                                                    page: page
                                                })
      if page_results.blank? or page_results["results"].blank?
        break
      end
      results.concat(page_results["results"])
    end
    return results
  end

  def get_best_company_by_name(name)
    results = Clearbit::Discovery.search({
                                             query: {name: name},
                                             sort: 'google_rank',
                                             page_size: 1
                                         })
    if results.blank? or results['results'].blank?
      return nil
    else
      return results['results'].first
    end
  end

  def remove_subdomain(host)
    # Not complete. Add all root domain to regexp
    host.sub(/.*?([^.]+(\.com|\.co\.uk|\.uk|\.nl))$/, "\\1")
  end

  def get_company_by_domain(domain)
    results = Clearbit::Discovery.search({
                                             query: {domain: domain},
                                             sort: 'google_rank',
                                             page_size: 1
                                         })
    if results.blank? or results['results'].blank?
      return nil
    else
      return results['results'].first
    end
  end

  def get_company_by_url(url)
    # getting host just incase
    host = URI.parse(url).host.downcase
    result = get_company_by_domain(host)
    if result.blank?
      host = remove_subdomain(host)
      result = get_company_by_domain(host)
    end
    return result
  end

  def get_company_by_industry(industry, page_size=1, sort='google_rank')
    results = Clearbit::Discovery.search({
                                             query: {industry: industry, country: 'US'},
                                             sort: sort,
                                             page_size: page_size
                                         })
    if results.blank? or results['results'].blank?
      return nil
    else
      return results['results']
    end
  end

  def get_leads_by_company_domain(domain)
    titles = COLLEGE_RECRUITER_TITLES
    titles.concat(OTHER_RECRUITER_TITLES)
    titles.concat(FOUNDER_TITLES)
    begin
      people = []
      # taking titles in groups of 3
      titles_enum = titles.each_slice(3)
      titles_enum.each do |titles|
        begin
          people.concat(Clearbit::Prospector.search(domain: domain, titles: titles, email: true, limit: PROSPECTOR_COUNT))
        rescue Exception
          next
        end
        if people.count() > 10
          break
        end
      end
      return people
    rescue Exception
      return []
    end
  end

  def get_leads_by_company_url(url)
    host = URI.parse(url).host.downcase
    # get base host
    host = PublicSuffix.parse(host).domain
    host = host.gsub('www.', '')
    return get_leads_by_company_domain(host)
  end

  def get_leads_by_company(company)
    if company.blank?
      return nil
    end
    if company["meta_data"].blank?
      return nil
    end
    if company["meta_data"]["url"].blank?
      return nil
    end
    return get_leads_by_company_url(company["meta_data"]["url"])
  end

end
