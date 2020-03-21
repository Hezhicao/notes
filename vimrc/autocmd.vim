augroup common
    autocmd!
    autocmd FileType python set foldmethod=indent
    autocmd FileType python set foldlevel=1
    autocmd FileType markdown set foldmethod=expr
    autocmd FileType cpp set foldmethod=syntax
    autocmd FileType snippets hi clear snipLeadingSpaces
    " Close the preview window when completion is done
    autocmd CompleteDone * if pumvisible() == 0 | pclose | endif
    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" You can add a mapping to `/` in order to open the vista finder for
" searching by adding the following autocommand in your vimrc:
" autocmd FileType vista,vista_kind nnoremap <buffer> <silent> \
         " / :<C-u>call vista#finder#fzf#Run()<CR>
