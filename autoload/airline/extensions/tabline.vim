" MIT License. Copyright (c) 2013 Bailey Ling.
" vim: et ts=2 sts=2 sw=2

let s:fmod = get(g:, 'airline#extensions#tabline#fnamemod', ':p:.')
let s:excludes = get(g:, 'airline#extensions#tabline#excludes', [])
let s:buf_nr_show = get(g:, 'airline#extensions#tabline#buffer_nr_show', 0)
let s:buf_nr_format = get(g:, 'airline#extensions#tabline#buffer_nr_format', '%s: ')
let s:buf_modified_symbol = g:airline_symbols.modified

function! airline#extensions#tabline#init(ext)
  if has('gui_running')
    set guioptions-=e
  endif
  set showtabline=2
  set tabline=%!airline#extensions#tabline#get()

  call a:ext.add_theme_func('airline#extensions#tabline#load_theme')
endfunction

function! airline#extensions#tabline#load_theme(palette)
  let l:tab = get(a:palette, 'airline_tab', a:palette.normal.airline_b)
  let l:tabsel = get(a:palette, 'airline_tabsel', a:palette.normal.airline_a)
  let l:tabtype = get(a:palette, 'airline_tabtype', a:palette.visual.airline_a)
  let l:tabfill = get(a:palette, 'airline_tabfill', a:palette.normal.airline_c)
  let l:tabmod = get(a:palette, 'airline_tabmod', a:palette.insert.airline_a)
  call airline#highlighter#exec('airline_tab', l:tab)
  call airline#highlighter#exec('airline_tabsel', l:tabsel)
  call airline#highlighter#exec('airline_tabtype', l:tabtype)
  call airline#highlighter#exec('airline_tabfill', l:tabfill)
  call airline#highlighter#exec('airline_tabmod', l:tabmod)
endfunction

function! airline#extensions#tabline#get()
  if tabpagenr('$') == 1
    return s:get_buffers()
  else
    return s:get_tabs()
  endif
endfunction

function! airline#extensions#tabline#title(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  return airline#extensions#tabline#get_buffer_name(buflist[winnr - 1])
endfunction

function! airline#extensions#tabline#get_buffer_name(nr)
  let _ = ''
  let name = bufname(a:nr)

  if s:buf_nr_show
    let _ .= printf(s:buf_nr_format, a:nr)
  endif

  if empty(name)
    let _ .= '[No Name]'
  else
    let _ .= fnamemodify(name, s:fmod)
  endif

  if getbufvar(a:nr, '&modified') == 1
    let _ .= s:buf_modified_symbol
  endif

  return _
endfunction

function! s:get_buffers()
  let b = airline#builder#new({'active': 1})
  let cur = bufnr('%')
  for nr in range(1, bufnr('$'))
    if buflisted(nr) && bufexists(nr)
      for ex in s:excludes
        if match(bufname(nr), ex)
          continue
        endif
      endfor
      if cur == nr
        if g:airline_detect_modified && getbufvar(nr, '&modified')
          let group = 'airline_tabmod'
        else
          let group = 'airline_tabsel'
        endif
      else
        let group = 'airline_tab'
      endif
      call b.add_section(group, '%( %{airline#extensions#tabline#get_buffer_name('.nr.')} %)')
    endif
  endfor
  call b.add_section('airline_tabfill', '')
  call b.split()
  call b.add_section('airline_tabtype', ' buffers ')
  return b.build()
endfunction

function! s:get_tabs()
  let b = airline#builder#new({'active': 1})
  for i in range(1, tabpagenr('$'))
    let group = i == tabpagenr() ? 'airline_tabsel' : 'airline_tab'
    call b.add_section(group, ' %{len(tabpagebuflist('.i.'))}%( %'.i.'T %{airline#extensions#tabline#title('.i.')} %)')
  endfor
  call b.add_raw('%T')
  call b.add_section('airline_tabfill', '')
  call b.split()
  call b.add_section('airline_tab', ' %999XX ')
  call b.add_section('airline_tabtype', ' tabs ')
  return b.build()
endfunction
