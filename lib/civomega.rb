def answer_civomega_question(question)
  response = "According to CivOmega.com... "
  answer = RestClient.get("http://www.civomega.com/ask?question=#{URI.encode(question)}").body
  answer_doc = Nokogiri::HTML(answer)
  answer_table = answer_doc.xpath('//table')
  selected_answers = answer_table.xpath('//table/tbody/tr').first(3).map do |tr|
    tr.xpath('td').map(&:text)
  end

  response_html = <<-EOS
    <article style="left: 0px; visibility: visible;">
      <section>
        <p class="text-minor">Top 3 CivOmega.com answers to '#{question}'</p>
        <table class="text-small">
          <tbody>
            <tr>
              <td>1. #{selected_answers[0][0]}</td>
              <td><div class="text-minor align-right muted">#{selected_answers[0][1]}</div></td>
            </tr>
            <tr>
              <td>2. #{selected_answers[1][0]}</td>
              <td><div class="text-minor align-right muted">#{selected_answers[1][1]}</div></td>
            </tr>
            <tr>
              <td>3. #{selected_answers[2][0]}</td>
              <td><div class="text-minor align-right muted">#{selected_answers[2][1]}</div></td>
            </tr>
          </tbody>
        </table>
      </section>
      <footer>
        <p class="text-minor muted">glassware by @skram</p>
      </footer>
    </article>
  EOS

  return {
    :html => response_html,
    :speakableType => "Question and Answer",
    :speakableText => "The top 3 answers from Civ Omega for the question, #{question}, are: ",    
    :menuItems => [{ :action => 'OPEN_URI', :payload => "http://www.civomega.com/?q=#{question}"}, { :action => 'READ_ALOUD' }, { :action => 'DELETE' } ]
  }

end