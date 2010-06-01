Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA676B01CD
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 17:19:46 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o51LJhe7000776
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 14:19:43 -0700
Received: from pzk32 (pzk32.prod.google.com [10.243.19.160])
	by wpaz29.hot.corp.google.com with ESMTP id o51LJfBH027847
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 14:19:42 -0700
Received: by pzk32 with SMTP id 32so2667891pzk.21
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 14:19:41 -0700 (PDT)
Date: Tue, 1 Jun 2010 14:19:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 13/18] oom: avoid race for oom killed tasks detaching
 mm prior to exit
In-Reply-To: <20100601204342.GC20732@redhat.com>
Message-ID: <alpine.DEB.2.00.1006011415190.16725@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010016460.29202@chino.kir.corp.google.com> <20100601164026.2472.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006011158230.32024@chino.kir.corp.google.com>
 <20100601204342.GC20732@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010, Oleg Nesterov wrote:

> On 06/01, David Rientjes wrote:
> >
> > No, it applies to mmotm-2010-05-21-16-05 as all of these patches do. I
> > know you've pushed Oleg's patches
> 
> (plus other fixes)
> 

You're suggesting that I should develop my patches on top of what I 
speculate that Andrew will eventually merge in -mm?  I don't have that 
kind of time, sorry.

> > but they are also included here so no
> > respin is necessary unless they are merged first (and I think that should
> > only happen if Andrew considers them to be rc material).
> 
> Well, I disagree.
> 
> I think it is always better to push the simple bugfixes first, then
> change/improve the logic.
> 

Unless your fixes, which seem to still be under development considering 
your discussion with KOSAKI in those threads, are going into 2.6.35 during 
the rc cycle, then there's no difference in them being merged as part of 
this patchset since they are duplicated here.  So you'll need to convince 
Andrew they are rc material otherwise it doesn't matter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
