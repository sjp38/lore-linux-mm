Date: Fri, 24 Aug 2001 15:40:02 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: VM problem with 2.4.8-ac9 (fwd)
In-Reply-To: <E15aKxw-0006BC-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.21.0108241538380.4787-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Jari Ruusu <jari.ruusu@pp.inet.fi>, Hugh Dickins <hugh@veritas.com>, Rik van Riel <riel@conectiva.com.br>, Jeremy Linton <jlinton@interactivesi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 24 Aug 2001, Alan Cox wrote:

> > VM torture results of 2.4.8-ac9 + Hugh's patch (version 23 Aug 2001
> > 21:24:50), 8 hours of torture. 1 incident where a process died with SIGSEGV.
> > No "swap offset" messages.
> 
> Great - Hugh can you forward me a copy of the patch.

Wait, 

I do not feel comfortable with random SIGSEGV messages.

If we are getting those, I suspect there is still some broken thing in
do_swap_page().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
