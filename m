Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8252B6B01EE
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 21:39:22 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3R1dIS5003429
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 27 Apr 2010 10:39:18 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F0FD45DE4E
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 10:39:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F114145DD77
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 10:39:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D1E5E1DB8037
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 10:39:17 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 868781DB803B
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 10:39:14 +0900 (JST)
Date: Tue, 27 Apr 2010 10:35:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: swapping when there's a free memory
Message-Id: <20100427103517.ae0658cf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100426153333.93c03e98.akpm@linux-foundation.org>
References: <alpine.DEB.1.10.1004220248280.19246@artax.karlin.mff.cuni.cz>
	<20100425071349.GA1275@ucw.cz>
	<20100426153333.93c03e98.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Machek <pavel@ucw.cz>, Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 26 Apr 2010 15:33:33 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Sun, 25 Apr 2010 09:13:49 +0200
> Pavel Machek <pavel@ucw.cz> wrote:
> 
> > Hi!
> > 
> > > I captured this output of vmstat. The machine was freeing cache and 
> > > swapping out pages even when there was a plenty of free memory.
> > > 
> > > The machine is sparc64 with 1GB RAM with 2.6.34-rc4. This abnormal 
> > > swapping happened during running spadfsck --- a fsck program for a custom 
> > > filesystem that caches most reads in its internal cache --- so it reads 
> > > buffers and allocates memory at the same time.
> > > 
> > > Note that sparc64 doesn't have any low/high memory zones, so it couldn't 
> > > be explained by filling one zone and needing to allocate pages in it.
> > 
> > Fragmented memory + high-order allocation?
> 
> Yeah, could be.  I wonder which slab/slub/slob implementation you're
> using, and what page sizes it uses for dentries, inodes, etc.  Can you
> have a poke in /prob/slabinfo?
> 
And please /proc/buddyinfo and /proc/zoneinfo when the system is swappy.

Thanks,
-Kame

> 
> > > This abnormal behavior doesn't happen everytime, it happend about twice 
> > > for many spadfsck attempts.
> > 
> > ...yep, that would be random.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
