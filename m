Date: Tue, 3 Oct 2000 01:29:27 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.21.0010021956410.1067-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0010030127050.17037-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, MM mailing list <linux-mm@kvack.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Rik van Riel wrote:

> > > > another thing is the complexity of marking a page dirty - right
> > > > now we can assume that page->buffers holds all the blocks. With
> > > > aging we must check wether a bh is there or not,
> > > 
> > > The code must already be able to handle this. This is nothing new.
> > 
> > sure this is new. The page->buffers list right now is assumed to
> > stay constant after being created.
> 
> Eeeeeek. So pages /cannot/ lose their buffer heads ???

it can and does lose them - but only all of them. Aging OTOH is a per-bh
thing, this kind of granularity is simply not present in the current
page->buffers handling. This is all i wanted to mention. Not unsolvable,
but needs extra logic.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
