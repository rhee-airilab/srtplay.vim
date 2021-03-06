"

if exists('g:srtplay_loaded')
    finish
endif
let g:srtplay_loaded=1

autocmd BufEnter *.srt nnoremap <buffer> gg :call <sid>PlayBlock()
autocmd BufEnter *.srt nnoremap <buffer> gn :call <sid>NextBlock()
autocmd BufEnter *.srt nnoremap <buffer> g; :call <sid>ChangeTempo()
autocmd BufEnter *.srt set so=7

let g:srt_block_pattern = '^\(\d\+\)\_s\(\d\{2\}\):\(\d\{2\}\):\(\d\{2\}\),\(\d\{3\}\) --> \(\d\{2\}\):\(\d\{2\}\):\(\d\{2\}\),\(\d\{3\}\)'
let g:srt_timestamp_pattern = '^\(\d\{2\}\):\(\d\{2\}\):\(\d\{2\}\),\(\d\{3\}\) --> \(\d\{2\}\):\(\d\{2\}\):\(\d\{2\}\),\(\d\{3\}\)$'
let g:srt_mode_play_fmt = 'play -q -n synth 0.1 tri 1000.0 vol 0.2; play -q "%s" trim 0:00:%f 0:00:%f tempo %f; exec play -q -n synth 0.1 tri 500.0 vol 0.2'
let g:srt_mode_tempo_list = [0.5, 0.75, 1.0, 1.11, 1.22, 1.33, 1.44]
let g:srt_mode_tempo_sel  = 2


function! s:NextBlock()
    call search(g:srt_block_pattern,'W')
endfunction

function! s:PlaySegment(wavfile,tm_st_f,tm_ed_f,tempo_f)
    let wavfile = a:wavfile
    let seek_to = a:tm_st_f
    let endpos  = a:tm_ed_f - a:tm_st_f
    let tempo   = a:tempo_f
    let cmd     = printf(g:srt_mode_play_fmt,wavfile,seek_to,endpos,tempo)
    :silent let output = system(cmd)
endfunction

function! s:ChangeTempo()
    let g:srt_mode_tempo_sel = (g:srt_mode_tempo_sel + 1) % len(g:srt_mode_tempo_list)
    echom printf('SRT-mode: tempo changed: %f', g:srt_mode_tempo_list[g:srt_mode_tempo_sel])
endfunction

function! s:PlayBlock()
    let pos = search(g:srt_block_pattern, 'bcW')
    if pos > 0
	let blocknum = getline(pos)
	let matched = matchlist(getline(pos+1), g:srt_timestamp_pattern)
	let hh1     = str2float(matched[1])
	let mm1	    = str2float(matched[2])
	let ss1	    = str2float(matched[3])
	let uu1	    = str2float(matched[4])
	let hh2	    = str2float(matched[5])
	let mm2	    = str2float(matched[6])
	let ss2	    = str2float(matched[7])
	let uu2	    = str2float(matched[8])
	let tstart  = hh1*3600 + mm1*60 + ss1 + uu1 * 0.001
	let tstop   = hh2*3600 + mm2*60 + ss2 + uu2 * 0.001
	" echom printf('blocknum %d tstart %f tstop %f',blocknum,tstart,tstop)
	let fn	    = resolve(expand('%'))
	let wn	    = fnamemodify(fn,':r') . '.wav'
	call s:PlaySegment(wn,tstart,tstop,g:srt_mode_tempo_list[g:srt_mode_tempo_sel])
	call s:NextBlock()
    endif
endfunction
