" MakeDoxygenComment.vim
" Brief: Creates a Doxygen style comment block for a function.
" Version: 0.1.4 
" Date: 18/4/13
" Author: Leif Wickland, Ryan De Boer 
"
" Generates a doxygen comment skeleton for a C, C++,  or Java function,
" including @brief, @param (for each named argument), and @return.  The tag
" text as well as a comment block header and footer are configurable.
" (Consequently, you can have \brief, etc. if you wish, with little effort.)
"
" It's definitely a little rough around the edges, but I hope you find it
" useful.
" 
" To use:  In vim with the cursor on the line of the function header that
" contains the parameters (if any), execute the command :Dox.  This will
" generate the skeleton and leave the cursor after the @brief tag.
"
" Limitations:
" - Assumes that the function has a blank line above it and that all of the
"   parameters are on the same line.  
" - Not able to update a comment block after it's been written.
"
" Example:
" Given:
" int foo(char mychar, int yourint, double myarray[])
" { //...
" }
"
" Issuing the :Dox command with the cursor on the function declaration would
" generate
" 
" /**
" * @brief 
" *
" * @param mychar 
" * @param myint 
" * @param myarray 
" *
" * @return 
" **/
"
" To customize the output of the script, see the g:MakeDoxygenComment_*
" variables in the script's source.  These variables can be set in your
" .vimrc.
"
" For example, my .vimrc contains:
" let g:MakeDoxygenComment_briefTag="@Synopsis  "
" let g:MakeDoxygenComment_paramTag="@Param "
" let g:MakeDoxygenComment_returnTag="@Returns   "
" let g:MakeDoxygenComment_blockHeader="--------------------------------------------------------------------------"
" let g:MakeDoxygenComment_blockFooter="----------------------------------------------------------------------------"
if exists("loaded_MakeDoxygenComment")
    "echo 'MakeDoxygenComment Already Loaded.'
    finish
endif
let loaded_MakeDoxygenComment = 1
"echo 'Loading MakeDoxygenComment...'

if !exists("g:MakeDoxygenComment_briefTag")
    let g:MakeDoxygenComment_briefTag="@brief "
endif
if !exists("g:MakeDoxygenComment_paramTag")
    let g:MakeDoxygenComment_paramTag="@param "
endif
if !exists("g:MakeDoxygenComment_returnTag")
    let g:MakeDoxygenComment_returnTag="@return "
endif
if !exists("g:MakeDoxygenComment_blockHeader")
    let g:MakeDoxygenComment_blockHeader=""
endif
if !exists("g:MakeDoxygenComment_blockFooter")
    let g:MakeDoxygenComment_blockFooter=""
endif

function! <SID>MakeDoxygenComment()
    mark d
    let l:line=getline(line("."))
    exec "normal {"
    if (g:MakeDoxygenComment_briefTag=="")
        exec "normal o/**" . g:MakeDoxygenComment_blockHeader ."\<cr>" . ' ' ."\<bs>"
    else
        exec "normal o/**" . g:MakeDoxygenComment_blockHeader ."\<cr>" . g:MakeDoxygenComment_briefTag
    endif
    let l:synopsisLine=line(".")
    let l:synopsisCol=col(".")
    let l:nextParamLine=l:synopsisLine+2
    if (match(l:line, "void")!=-1)
        exec "normal a\<cr>\<cr>\<cr>\<cr>\<bs>" . g:MakeDoxygenComment_blockFooter . "*/"
    else
        exec "normal a\<cr>\<cr>\<cr>\<cr>\<cr>" . g:MakeDoxygenComment_returnTag . "\<cr>\<bs>" . g:MakeDoxygenComment_blockFooter . "*/"
    endif
    exec "normal `d"
    let l:startPos=match(l:line, "(")
    let l:identifierRegex='\i\+[\s\[\]]*[,)]'
    let l:matchIndex=match(l:line,identifierRegex,l:startPos)
    let l:tabSize=0
    if (match(l:line, "\t")!=-1)
        let l:tabSize=3
    endif
    let l:foundParam=0
    while (l:matchIndex >= 0)
        let l:foundParam=1
        let l:getWordIndex=l:matchIndex+1+l:tabSize
        exec "normal " . (l:getWordIndex) . "|"
        let l:param=expand("<cword>")
        exec l:nextParamLine
        exec "normal O" . g:MakeDoxygenComment_paramTag . l:param . " "
        let l:nextParamLine=l:nextParamLine+1

        exec "normal `d"
"        echo "l:tabSize=" . l:tabSize
"        echo "l:startPos before: " . l:startPos
"        echo "l:matchIndex = " . l:matchIndex
"        echo "l:getWordIndex = " . l:getWordIndex
"        echo "strlen=" . strlen(l:param)
"        echo "total=" . (l:matchIndex+strlen(l:param)+1)
        let l:startPos=(l:matchIndex+strlen(l:param)+1)
"        echo "l:startPos after: " . l:startPos
        let l:matchIndex=match(l:line,identifierRegex,l:startPos)
    endwhile

    exec l:nextParamLine
    exec "normal dj"
    if (l:foundParam < 1)
        exec "normal dd"
    endif
    exec l:synopsisLine
    exec "normal " . l:synopsisCol . "|"
    startinsert!
endfunction

command! -nargs=0 Dox :call <SID>MakeDoxygenComment()
