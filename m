Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 0E72938CFF
	for <linux-mm@kvack.org>; Thu, 23 Aug 2001 17:37:20 -0300 (EST)
Date: Thu, 23 Aug 2001 17:37:00 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: VM problem with 2.4.8-ac9 (fwd)
In-Reply-To: <E15a16U-0004Yg-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.33L.0108231735480.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Hugh Dickins <hugh@veritas.com>, Jari Ruusu <jari.ruusu@pp.inet.fi>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jeremy Linton <jlinton@interactivesi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2001, Alan Cox wrote:

> > 1. lock_kiovec page unwind fix (velizarb@pirincom.com)
> > 2. copy_cow_page & clear_user_highpage can block in kmap
> >    (Anton Blanchard, Ingo Molnar, Linus Torvalds, Hugh Dickins)

I don't know enough about this code to properly fix it...

> > 3. do_swap_page recheck pte before failing (Jeremy Linton, Linus Torvalds)
> > 4. do_swap_page don't mkwrite when deleting from swap cache (Linus Torvalds)

I'll look at these. I'll carefully merge some of Linus'
stuff here. Careful because Linus seems to be getting
various other things in eg. memory.c wrong and stripped
off the comments of some pieces of code ;)

cheers,

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
