def answer_civomega_question(question = "", n_answers = 3)
  question = question.gsub("who's","who is")
  attribution = "app (not data) by @skram"
  response = "According to CivOmega.com... "

  # fetch answer from site and parse the answer set
  answer = RestClient.get("http://www.civomega.com/ask?question=#{URI.encode(question)}").body
  answer_doc = Nokogiri::HTML(answer)
  answer_table = answer_doc.xpath('//table')

  # if there was at least one answer
  if answer_table.size > 0

    # create array of items to answer the question
    selected_answers = answer_table.xpath('//table/tbody/tr').first(n_answers).map do |tr|
      tr.xpath('td').map(&:text)
    end

    # formulate the response HTML as well as a text version
    response_text = "The top #{n_answers} answers from Civ Omega for the question, #{question}, are: "
    response_html = <<-EOS
      <article style="left: 0px; visibility: visible;">
        <section>
          <p class="text-minor">Top #{n_answers} CivOmega.com answers to '#{question}'</p>
          <table class="text-small">
            <tbody>
    EOS

    selected_answers.each_with_index do |item,n|
      response_text += "#{n+1}, #{item[0]}, #{item[1]} ,,"
      response_html += "<tr><td>#{n+1}. #{item[0]}</td><td><div class='text-minor align-right muted'>#{item[1]}</div></td></tr>"
    end

    response_text += ", #{attribution}"
    response_html += <<-EOS
            </tbody>
          </table>
        </section>
        <footer>
          <p class="text-minor muted">#{attribution}</p>
        </footer>
      </article>
    EOS

    card_hash = {
      :html => response_html,
      :speakableText => response_text,
      :speakableType => "Open Data Question and Answer",
      :menuItems => [{ :action => 'OPEN_URI', :payload => "http://www.civomega.com/?q=#{question}"}, { :action => 'READ_ALOUD' }, { :action => 'DELETE' } ]
    }

  else # if there was no answer
    card_hash = {
      :text => "Sorry, CivOmega did not have an answer to '#{question}'",
      :speakableType => "Question and Answer",
      :speakableText => "Sorry, CivOmega.com did not have an answer to '#{question}'",
      :menuItems => [{ :action => 'READ_ALOUD' }, { :action => 'DELETE' } ]
    }
  end

  return card_hash

end