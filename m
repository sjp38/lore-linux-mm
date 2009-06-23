Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5DE676B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 02:07:55 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5N685G8005548
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 23 Jun 2009 15:08:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BFA0C45DE63
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 15:08:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8845545DE64
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 15:08:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B7641DB803E
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 15:08:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F365CE08002
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 15:08:03 +0900 (JST)
Date: Tue, 23 Jun 2009 15:06:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
Message-Id: <20090623150630.31c0dff5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1245736441.18339.21.camel@alok-dev1>
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>
	<1245732411.18339.6.camel@alok-dev1>
	<20090623135017.220D.A69D9226@jp.fujitsu.com>
	<20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>
	<1245736441.18339.21.camel@alok-dev1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akataria@vmware.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Jun 2009 22:54:01 -0700
Alok Kataria <akataria@vmware.com> wrote:

> > > 
> > > I don't have any strong oppose reason, but I also don't have any strong
> > > agree reason.
> > > 
> > I think "don't include Hugepage" is sane. Hugepage is something _special_, now.
> > 
> Kamezawa-san, 
> 
> I agree that hugepages are special in the sense that they are
> implemented specially and don't actually reside on the LRU like any
> other locked memory. But, both of these memory types (mlocked and
> hugepages) are actually unevictable and can't be reclaimed back, so i
> don't see a reason why should accounting not reflect that.
> 

I bet we should rename "Unevictable" to "Mlocked" or "Pinned" rather than
take nr_hugepages into account. I think this "Unevictable" in meminfo means
- pages which are evictable in their nature (because in LRU) but a user pinned it -

How about rename "Unevictable" to "Pinned" or "Locked" ?
(Mlocked + locked shmem's + ramfs?)

We have other "unevictable" pages other than Hugepage anyway.
 - page table
 - some slab
 - kernel's page
 - anon pages in swapless system
 etc...

BTW, I use following calculation for quick check if I want all "Unevicatable" pages.

Unevictable = Total - (Active+Inactive) + (50-70%? of slab)

This # of is not-reclaimable memory.

Thanks,
-Kame


> Thanks,
> Alok
> 
> > Thanks,
> > -Kame
> > 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
