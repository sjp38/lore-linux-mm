Subject: Re: VM problem with 2.4.8-ac9 (fwd)
Date: Thu, 23 Aug 2001 21:29:26 +0100 (BST)
In-Reply-To: <Pine.LNX.4.21.0108232049530.1020-100000@localhost.localdomain> from "Hugh Dickins" at Aug 23, 2001 09:24:50 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15a16U-0004Yg-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Jari Ruusu <jari.ruusu@pp.inet.fi>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Jeremy Linton <jlinton@interactivesi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Alan has intentionally been avoiding many of the VM "fixes" in Linus'
> tree, Rik has been feeding him some of the less controversial ones,
> but I believe there are important ones missing (unrelated to aging
> and tuning etc.).  Looking no further than mm/memory.c, patch below
> to bring 2.4.8-ac9 in line with 2.4.9 there:
> 
> 1. lock_kiovec page unwind fix (velizarb@pirincom.com)
> 2. copy_cow_page & clear_user_highpage can block in kmap
>    (Anton Blanchard, Ingo Molnar, Linus Torvalds, Hugh Dickins)
> 3. do_swap_page recheck pte before failing (Jeremy Linton, Linus Torvalds)
> 4. do_swap_page don't mkwrite when deleting from swap cache (Linus Torvalds)

I've been avoiding the Linus paging ones because they seem to make my
machines all crash repeatedly under any kind of serious test load. Plus the
fact that after about 3 days they needed rebooting to get back from 386 
speed.

Rik traced down some more vm races so hopefully ac11 will have some more 
progress on this one.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
