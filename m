Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A9EC86B0078
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 08:26:19 -0500 (EST)
Date: Tue, 19 Jan 2010 15:26:08 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100119132608.GQ14345@redhat.com>
References: <20100118181942.GD22111@redhat.com>
 <20100118191031.0088f49a@lxorguk.ukuu.org.uk>
 <20100119071734.GG14345@redhat.com>
 <84144f021001182337o274c8ed3q8ce60581094bc2b9@mail.gmail.com>
 <20100119075205.GI14345@redhat.com>
 <84144f021001190007q54a334dfwed64189e6cf0b7c4@mail.gmail.com>
 <20100119082638.GK14345@redhat.com>
 <84144f021001190044s397c6665qb00af48235d2d818@mail.gmail.com>
 <1263905332.2163.11.camel@barrios-desktop>
 <84144f021001190518x450868eax2edfa5e16ff6e4b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f021001190518x450868eax2edfa5e16ff6e4b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Minchan Kim <minchan.kim@gmail.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 19, 2010 at 03:18:11PM +0200, Pekka Enberg wrote:
> On Tue, Jan 19, 2010 at 2:48 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> > Gleb. How about using MADV_SEQUENTIAL on guest memory?
> > It makes that pages of guest are moved into inactive reclaim list more
> > fast. It means it is likely to swap out faster than other pages if it
> > isn't hit during inactive list.
> 
> Yeah, something like that but we don't want the readahead. OTOH, it's
> not clear what Gleb's real problem is. Are the guest address spaces
> anonymous or file backed?
Anonymous.

>                           Which parts of the emulator are swapped out
> that are causing the problem?
I don't want anything that can be used during guest runtime to be
swapped out. And I run 2G guest in 512M container, so eventually
everything is swapped out :)

>                                Maybe it's a VM balancing issue that
> mlock papers over?
> 
There is no problem. I do measurements on how host swapping affects
guest and I don't want qemu code to be swapped out.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
