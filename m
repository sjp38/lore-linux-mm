Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 72EA26B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 23:30:00 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n084Tvsb032761
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Jan 2009 13:29:57 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 036C645DD78
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 13:29:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4CA045DD72
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 13:29:58 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AE3A1DB8042
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 13:29:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F38F01DB803C
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 13:29:56 +0900 (JST)
Date: Thu, 8 Jan 2009 13:28:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/4] Memory controller soft limit organize cgroups
Message-Id: <20090108132855.77d3d3d4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090108042558.GC7294@balbir.in.ibm.com>
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain>
	<20090107184128.18062.96016.sendpatchset@localhost.localdomain>
	<20090108101148.96e688f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090108042558.GC7294@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jan 2009 09:55:58 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-08 10:11:48]:
> > Hmm,  Could you clarify following ?
> >   
> >   - Usage of memory at insertsion and usage of memory at reclaim is different.
> >     So, this *sorted* order by RB-tree isn't the best order in general.
> 
> True, but we frequently update the tree at an interval of HZ/4.
> Updating at every page fault sounded like an overkill and building the
> entire tree at reclaim is an overkill too.
> 
"sort" is not necessary.
If this feature is implemented as background daemon,
just select the worst one at each iteration is enough.


> >     Why don't you sort this at memory-reclaim dynamically ?
> >   - Considering above, the look of RB tree can be
> > 
> >                 +30M (an amount over soft limit is 30M)
> >                 /  \
> >              -15M   +60M
> 
> We don't have elements below their soft limit in the tree
> 
> >      ?
> > 
> >     At least, pleease remove the node at uncharge() when the usage goes down.
> >
> 
> We do remove the tree if it goes under its soft limit at commit_charge,
> I thought I had the same code in uncharge(), but clearly that is
> missing. Thanks, I'll add it there.
> 

Ah, ok. I missed it. Thank you for clalification.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
