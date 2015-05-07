require 'cinch'
require 'marky_markov'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "db"
    c.realname = "db"
    c.user = "db"
    c.server = "irc.amazdong.com"
    c.channels = ["#interns", "#ssl"]
    #c.server = "irc.darchoods.net"
    #c.channels = ["#thunked"]
    c.verbose = true
    #c.reconnect = true
  end

  helpers do
    def markov
      @markov ||= begin
        dictionary = MarkyMarkov::Dictionary.new('dictionary', 3)
        %w{
          ulysses 50shades
        }.each {|corpus| dictionary.parse_file "corpus/#{corpus}.txt" }
        dictionary.save_dictionary!
        dictionary
      end
    end

    def save_dictionary
      @markov.save_dictionary!
    end

    def build_ngrams_from line
      markov.parse_string line
    end

    def response_for trigger
      humanize markov.generate_n_words(7 + rand(4))
    end

    def humanize string
      string.downcase
        .gsub(/\s{2,}/, ' ')
        .gsub(/ i([!\?\.\s])/, ' I\1')
        .gsub(/([\.!\?] \w)+/, &:upcase) # properly capitalize after punctuation
        .gsub(/^\w/, &:upcase)
        .strip
        .gsub(/[\,;]$/, '')
        .downcase
        #.gsub(/([^!\.\?])$/, '\1.')
        
    end
  end

  on :message do |m|
    build_ngrams_from m.message

    save_dictionary if rand(100) < 10

    #m.reply(response_for m.message) if rand(100) < 5
  end

  on :message, /db/i do |m|
    m.reply(response_for m.message) if rand(100) < 8
  end
end

bot.start
