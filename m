Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9AD276B006A
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 19:24:09 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0K0O79j025642
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 Jan 2010 09:24:08 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AF81B45DE5C
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 09:24:07 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7761E45DE57
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 09:24:07 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AD911DB803F
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 09:24:07 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EF7451DB803C
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 09:24:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
In-Reply-To: <84144f021001190044s397c6665qb00af48235d2d818@mail.gmail.com>
References: <20100119082638.GK14345@redhat.com> <84144f021001190044s397c6665qb00af48235d2d818@mail.gmail.com>
Message-Id: <20100120091051.405D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Jan 2010 09:24:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: kosaki.motohiro@jp.fujitsu.com, Gleb Natapov <gleb@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

> Hi Gleb,
> 
> On Tue, Jan 19, 2010 at 10:26 AM, Gleb Natapov <gleb@redhat.com> wrote:
> >> design would still be broken, no? Did you try using (or extending)
> >> posix_madvise(MADV_DONTNEED) for the guest address space? It seems to
> > After mlockall() I can't even allocate guest address space. Or do you mean
> > instead of mlockall()? Then how MADV_DONTNEED will help? It just drops
> > page table for the address range (which is not what I need) and does not
> > have any long time effect.
> 
> Oh right, MADV_DONTNEED is no good.

Off topic:

posix_madvise(MADV_DONTNEED) is nop. glibc's posix_madvise(MADV_DONTNEED)
don't call linux's madvise(MADV_DONTNEED).
It's because madvise(MADV_DONTNEED) is not POSIX compliant. 

The behavior of linux madvise(MADV_DONTNEED) is similar to Solaris (or *BSD) 
madvise(MADV_FREE).




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
