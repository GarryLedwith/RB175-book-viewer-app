require "sinatra"
require "sinatra/reloader"

before do 
  @contents = File.readlines('data/toc.txt') 
end

helpers do 

  def in_paragraphs(chapter)
    chapter.split("\n\n").map.with_index do |paragraph, index|
      "<p id=paragraph#{index}>#{paragraph}</p>"
    end.join
  end

  def highlight_text(text, query)
    text.gsub(query, %(<strong>#{query}</strong>))
  end
end

not_found do 
  redirect "/"
end 

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home 
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]

  redirect "/" unless (1..@contents.size).include?(number) 

  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/search" do 
  search_word = params[:query]
  @word = search_word
  @hash = params 
  
  @chapters = matching_paragraphs(search_word)

  erb :search
end

def each_chapter
  name_and_contents = []

  @contents.each_with_index do |chapter_name, chapter_num|
    chapter_num += 1 
    chapter_contents = File.read("data/chp#{chapter_num}.txt")
    name_and_contents << [chapter_num, chapter_name, chapter_contents]
  end
 name_and_contents
end

def matching_chapter(search_query)
  chapter_match = []

  return chapter_match if search_query.nil? 

  each_chapter.each do |chapter|
    if chapter.last.include?(search_query)
      chapter_match << [chapter[0], chapter[1], chapter.last]
    end
  end
  chapter_match
end

def split_paragraphs(chapter)
  chapter.split("\n\n") 
end

def matching_paragraphs(search_query)
  all_matching_chapters = matching_chapter(search_query) 
  results = []
  
  all_matching_chapters.each do |chapter|
    hash = {number: chapter[0], name: chapter[1], paragraphs: []}
    
    chapter.last.split("\n\n").each do |paragraph|
      hash[:paragraphs] << paragraph if paragraph.include?(search_query)
    end 
    results << hash 
   end
   results
end







