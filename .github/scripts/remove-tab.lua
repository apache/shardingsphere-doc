local string = string
local stringify = pandoc.utils.stringify

function Inlines (inlines)
  local line_text = string.gsub(stringify(inlines), "%s+", "")
  line_text = string.gsub(line_text, "[“”]", "")
  line_text = string.gsub(line_text, "\"", "")
  if line_text == '{{<tabs>}}{{%tabname=Grammar%}}' or line_text == '{{<tabs>}}{{%tabname=语法%}}' then
	  return {}
  end

  if line_text == '{{%/tab%}}{{%tabname=Railroaddiagram%}}{{%/tab%}}{{</tabs>}}' or line_text == '{{%/tab%}}{{%tabname=铁路图%}}{{%/tab%}}{{</tabs>}}' then
	  return {}
  end
  return inlines
end

