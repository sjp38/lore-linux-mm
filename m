Date: Mon, 2 Oct 2000 18:27:01 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.10.10010021421150.826-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010021826110.1067-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Linus Torvalds wrote:
> On Mon, 2 Oct 2000, Rik van Riel wrote:
> > 
> > Would it be "close enough" to simply clear the buffer heads of
> > clean pages which make it to the front of the active list ?
> > 
> > Or is there another optimisation we could do to make the
> > approximation even better ?
> 
> I'd prefer it to be done as part of the LRU aging - we do watn
> to age all pages, and as part of the aging process we migth as
> well remove buffers that are lying around.

This was what I was proposing ;)

With, maybe, the optimisation that we don't want to do this
if we're simply doing background scanning and we don't have a
free memory shortage yet.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
