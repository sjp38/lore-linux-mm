Date: Wed, 17 Jan 2001 18:08:18 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <873denhe6l.fsf@atlas.iskon.hr>
Message-ID: <Pine.LNX.4.31.0101171807140.30841-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 13 Jan 2001, Zlatko Calusic wrote:

> 2.2.17     -> make -j32  392.49s user 47.87s system 168% cpu 4:21.13 total
> 2.4.0      -> make -j32  389.59s user 31.29s system 182% cpu 3:50.24 total
> 2.4.0-pre2 -> make -j32  393.32s user 138.20s system 129% cpu 6:51.82 total
> pre3-bgage -> make -j32  394.11s user 424.52s system 131% cpu 10:21.41 total

Hmmm, could you try my quick&dirty patch on
http://www.surriel.com/patches/  ?

Since I'm on linux.conf.au now, I don't have all
that much time to test these things myself, but I
have the idea this patch may be going in the right
direction.

If it is, I'll clean up more code and split up things
for Linus.

thanks,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
