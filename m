Date: Mon, 2 Apr 2001 21:19:33 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] Reclaim orphaned swap pages 
In-Reply-To: <Pine.LNX.4.21.0104021430160.12558-100000@jerrell.lowell.mclinux.com>
Message-ID: <Pine.LNX.4.21.0104022114110.6947-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Jerrell <jerrell@missioncriticallinux.com>
Cc: Szabolcs Szakacsits <szaka@f-secure.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 2 Apr 2001, Richard Jerrell wrote:

> > Actually if vm_enough_memory fails that prevents oom, apps get ENOMEM
> > instead of killed by oom_kill later. Moreover vm_enough_memory is long
> > different and apparently it's just overestimating free pages that makes
> > people unhappy with the resulted higher oom_kill/ENOMEM rate. If you
> 
> That's not really what I'm getting at.  Currently if you run a memory
> intensive application, quit after it's pages are on an lru, and try to
> restart, you won't be able to get the memory.  This is because pages which
> are sitting around in the swap cache are not counted as free, and they
> should be, because they are freeable.

No. Dirty swapcache pages which have pte's referencing them are not
freeable.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
