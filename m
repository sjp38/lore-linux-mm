Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 8A57E38D29
	for <linux-mm@kvack.org>; Wed, 22 Aug 2001 18:11:05 -0300 (EST)
Date: Wed, 22 Aug 2001 18:10:52 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] __alloc_pages_limit pages_min
In-Reply-To: <200108222103.f7ML3Lb26463@maile.telia.com>
Message-ID: <Pine.LNX.4.33L.0108221808490.31410-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2001, Roger Larsson wrote:
> On Wednesdayen den 22 August 2001 19:01, Rik van Riel wrote:
> > On Wed, 22 Aug 2001, Roger Larsson wrote:
> > > Note: reclaim_page will fix this situation direct it is allowed to
> > > run since it is kicked in __alloc_pages. But since we cannot
> > > guarantee that this will never happen...
> >
> > In this case kreclaimd will be woken up and the free pages
> > will be refilled.
>
> Yes it will be woken up - but when will it actually do something?

> And this limit at the end of alloc_pages
> 		if (z->free_pages < z->pages_min / 4 &&
> 				!(current->flags & PF_MEMALLOC))
> is not enforced earlier in the same code...

Please read the code.  The first loop in __alloc_pages(),
before we even call __alloc_pages_limit() will wake up
kreclaimd as soon as 'z->free_pages < z->pages_min'.

If you have any more questions about the source code,
don't hesitate to ask ;)

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
