"=============================================================================
" FILE: auto_mirroring.vim
" AUTHOR: Yoshihiro Ito <yo.i.jewelry.bab@gmail.com@gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================
let g:auto_mirroring_dir         = get(g:, 'auto_mirroring_dir',         expand('~/.vim/mirror'))
let g:auto_mirroring_max_history = get(g:, 'auto_mirroring_max_history', 7)

let s:is_windows = has('win32') || has('win64')
let s:is_unix    = has('unix')

let s:is_first_mirroring = 1

function! auto_mirroring#mirror_current_file()

  if s:is_first_mirroring
    let s:is_first_mirroring = 0
    call s:trim_mirror_dirs()
  endif

  let source_filepath = expand('%:p')

  if filereadable(source_filepath)
    let current_mirror_dir = g:auto_mirroring_dir . '/' . strftime('%Y%m%d')
    let current_postfix    = strftime('%H%M%S')
    let filename           = expand('%:p:t:r')
    let ext                = expand('%:p:t:e')

    if ext != ''
      let ext = '.' . ext
    endif

    let output_filepath = current_mirror_dir . '/' . filename . current_postfix . ext

    call s:make_dir(current_mirror_dir)
    call s:copy_file(source_filepath, output_filepath)
  endif
endfunction

function! s:trim_mirror_dirs()

  let mirror_dirs = sort(split(glob(g:auto_mirroring_dir . '/*'),  '\n'))

  while len(mirror_dirs) > g:auto_mirroring_max_history
    let dir = remove(mirror_dirs, 0)
    call s:remove_dir(dir)
  endwhile
endfunction

function! s:make_dir(path)

  if isdirectory(a:path) == 0
    call mkdir(a:path, 'p')
  endif
endfunction
" }}}

function! s:copy_file(sourceFilepath, targetFilepath)

  if !s:has_vimproc()
    echo 'vim-auto-mirroring is dependent on vimproc'
    return
  endif

  let esource = vimproc#shellescape(expand(a:sourceFilepath))
  let etarget = vimproc#shellescape(expand(a:targetFilepath))

  if s:is_windows
    call vimproc#system_bg('copy ' . esource . ' ' . etarget)
  elseif s:is_unix
    call vimproc#system_bg('cp ' . esource . ' ' . etarget)
  else
    echo 'auto_mirroring.copy_file : Not supported.'
  endif
endfunction

function! s:remove_dir(path)

  let epath = vimproc#shellescape(expand(a:path))

  if isdirectory(a:path)
    if s:is_windows
      call vimproc#system_bg('rd /S /Q ' . epath)
    elseif s:is_unix
      call vimproc#system_bg('rm -rf ' . epath)
    else
      echo 'auto_mirroring.remove_dir : Not supported.'
    endif
  endif
endfunction

function! s:has_vimproc()
  if !exists('s:exists_vimproc')
    try
      silent call vimproc#version()
      let s:exists_vimproc = 1
    catch
      let s:exists_vimproc = 0
    endtry
  endif
  return s:exists_vimproc
endfunction

" vim: set ts=2 sw=2 sts=2 et :
