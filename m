Message-ID: <3B868D81.2ADA3AD2@pp.inet.fi>
Date: Fri, 24 Aug 2001 20:23:13 +0300
From: Jari Ruusu <jari.ruusu@pp.inet.fi>
MIME-Version: 1.0
Subject: Re: VM problem with 2.4.8-ac9 (fwd)
References: <Pine.LNX.4.21.0108232049530.1020-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Jeremy Linton <jlinton@interactivesi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> 1. lock_kiovec page unwind fix (velizarb@pirincom.com)
> 2. copy_cow_page & clear_user_highpage can block in kmap
>    (Anton Blanchard, Ingo Molnar, Linus Torvalds, Hugh Dickins)
> 3. do_swap_page recheck pte before failing (Jeremy Linton, Linus Torvalds)
> 4. do_swap_page don't mkwrite when deleting from swap cache (Linus Torvalds)

VM torture results of 2.4.8-ac9 + Hugh's patch (version 23 Aug 2001
21:24:50), 8 hours of torture. 1 incident where a process died with SIGSEGV.
No "swap offset" messages.

glibc compile failed:
make[2]: *** [math/subdir_lib] Segmentation fault

Regards,
Jari Ruusu <jari.ruusu@pp.inet.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
