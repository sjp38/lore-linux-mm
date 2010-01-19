Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5E767600798
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 05:41:10 -0500 (EST)
Date: Tue, 19 Jan 2010 12:40:58 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100119104058.GL14345@redhat.com>
References: <20100118170816.GA22111@redhat.com>
 <84144f021001181009m52f7eaebp2bd746f92de08da9@mail.gmail.com>
 <20100118181942.GD22111@redhat.com>
 <20100118191031.0088f49a@lxorguk.ukuu.org.uk>
 <20100119071734.GG14345@redhat.com>
 <84144f021001182337o274c8ed3q8ce60581094bc2b9@mail.gmail.com>
 <20100119075205.GI14345@redhat.com>
 <84144f021001190007q54a334dfwed64189e6cf0b7c4@mail.gmail.com>
 <20100119082638.GK14345@redhat.com>
 <84144f021001190044s397c6665qb00af48235d2d818@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f021001190044s397c6665qb00af48235d2d818@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, Jan 19, 2010 at 10:44:23AM +0200, Pekka Enberg wrote:
> On Tue, Jan 19, 2010 at 10:26 AM, Gleb Natapov <gleb@redhat.com> wrote:
> >> me that you're trying to use a big hammer (mlock) when a polite hint
> >> for the VM would probably be sufficient for it do its job.
> >>
> > I what to tell to VM "swap this, don't swap that" and as far as I see
> > there is no other way to do it currently.
> 
> Yeah, which is why I was suggesting that maybe posix_madvise() needs
> to be extended to have a MADV_NEED_BUT_LESS_IMPORTANT flag that can be
> used as a hint by mm/vmscan.c to first swap the guest address spaces.
> 
If such thing would exist may be I would have used it since swapping out
of a wrong page is not live or death matter in my case, but mlockall()
provides me with exactly what I need and without swapping out wrong
pages. Speaking about adding such madvise call wouldn't it be even
harder to justify? It obviously not good enough for real-time use and my
case, I admit, is unusual. Also if we start prioritise memory why stop
on binary, why not set value like "this memory is more important then
that memory by factor of 5"?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
