Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D69376B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 01:29:00 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n475TQjj032729
	for <linux-mm@kvack.org> (envelope-from y-goto@jp.fujitsu.com);
	Thu, 7 May 2009 14:29:26 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 85B4F45DE5D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 14:29:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DAF345DE52
	for <linux-mm@kvack.org>; Thu,  7 May 2009 14:29:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DBFA61DB8044
	for <linux-mm@kvack.org>; Thu,  7 May 2009 14:29:18 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 00C361DB803C
	for <linux-mm@kvack.org>; Thu,  7 May 2009 14:29:16 +0900 (JST)
Date: Thu, 07 May 2009 14:29:15 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] Double check memmap is actually valid with a memmap has unexpected holes
In-Reply-To: <20090506155043.GA3084@cmpxchg.org>
References: <20090506143059.GB20709@csn.ul.ie> <20090506155043.GA3084@cmpxchg.org>
Message-Id: <20090507142143.0619.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hartleys@visionengravers.com, mcrapet@gmail.com, linux@arm.linux.org.uk, fred99@carolina.rr.com, linux-arm-kernel@lists.arm.linux.org.uk, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi.

> > > +		unsigned long pfn;
> > >  
> > > -		pgdat_resize_lock(pgdat, &flags);
> > 
> > How sure are you about removing the acquisition of this lock?  If anything,
> > it appears that pagetypeinfo_showblockcount_print() should be taking this lock.
> 
> I'm completely unsure about it.
> 
> <adds memory hotplug guys to CC>

zone->zone_start_pfn and zone->spanned_pages may be changed by memory hotplug.
The lock must be acquired before getting their values as Mel-san said.

Thanks.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
