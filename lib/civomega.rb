def answer_civomega_question(question)
  response = "According to CivOmega.com... "
  answer = RestClient.get("http://www.civomega.com/ask?question=#{URI.encode(question)}").body
  answer_doc = Nokogiri::HTML(answer)
  answer_table = answer_doc.xpath('//table')
  selected_answers = answer_table.xpath('//table/tbody/tr').first(3).map do |tr|
    tr.xpath('td').map(&:text).join(",")
  end
  response += selected_answers.join("; ") + " ... " + answer_doc.xpath('//p').text 
  return response
end