local function isDisplayMath(el)
  return el ~= nil and el.t == "Math" and el.mathtype == "DisplayMath"
end

local function isEqRef(el)
  return el ~= nil and el.t == "Str" and el.text:match("^{#eq-")
end

local function isNoEqRef(el)
  return el ~= nil and el.t == "Str" and el.text == "{#no-eq}"
end

local function findNextNonSpace(inlines, start)
    local i = start + 1
    -- TODO: There are probably other whitespace elements that need added here.
    while (i <= #inlines and (inlines[i].t == "Space" or inlines[i].t == "SoftBreak")) do
        i = i + 1
    end

    return i
end

unnameCounter = 0

-- TODO: Original (https://github.com/quarto-dev/quarto-cli/blob/56da834f07f5fdfab1e432f11aa3be6b26f4fd2a/src/resources/filters/crossref/equations.lua) has a function for `Plain` as well, should we add for this?
function Para(element)
  local inlines = element.content

  if inlines:find_if(isDisplayMath) == nil then
    return element
  end

  local i = 1
  while (i <= #inlines) do
    local math = inlines[i]

    local j = findNextNonSpace(inlines, i)
    local ref = inlines[j]

    if isDisplayMath(math) then
      if isNoEqRef(ref) then
        inlines:remove(j)
      elseif not isEqRef(ref) then
        inlines:insert(j, pandoc.Str("{#eq-unnamed-" .. unnameCounter .. "}"))
        unnameCounter = unnameCounter + 1
      end
    end

    i = i + 1
  end

  return element
end
