Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9657D6B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 22:21:09 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so1901792pde.38
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 19:21:09 -0700 (PDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so1898459pdi.5
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 19:21:07 -0700 (PDT)
Date: Wed, 16 Oct 2013 19:21:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/readahead.c: need always return 0 when system call
 readahead() succeeds
In-Reply-To: <525F3E39.3060603@asianux.com>
Message-ID: <alpine.DEB.2.02.1310161918260.21167@chino.kir.corp.google.com>
References: <5212E328.40804@asianux.com> <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org> <521428D0.2020708@asianux.com> <20130917155644.cc988e7e929fee10e9c86d86@linux-foundation.org> <52390907.7050101@asianux.com> <525CF787.6050107@asianux.com>
 <alpine.DEB.2.02.1310161603280.2417@chino.kir.corp.google.com> <525F35F7.4070202@asianux.com> <alpine.DEB.2.02.1310161812480.12062@chino.kir.corp.google.com> <525F3E39.3060603@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com, linux-mm@kvack.org

On Thu, 17 Oct 2013, Chen Gang wrote:

> > I think your patches should be acked before being merged into linux-next, 
> > Hugh just had to revert another one that did affect Linus's tree in 
> > 1ecfd533f4c5 ("mm/mremap.c: call pud_free() after fail calling
> > pmd_alloc()").  I had to revert your entire series of mpol_to_str() 
> > changes in -mm.  It's getting ridiculous and a waste of other people's 
> > time.
> > 
> 
> If always get no reply, what to do, next?
> 

If nobody ever acks your patches, they probably aren't that important.  At 
the very least, something that nobody has looked at shouldn't be included 
if it's going to introduce a regression.

> But all together, I welcome you to help ack/nack my patches for mm
> sub-system (although I don't know your ack/nack whether have effect or not).
> 

If it touches mm, then there is someone on this list who can ack it and 
you can cc them by looking at the output of scripts/get_maintainer.pl.  If 
nobody is interested in it, or if it doesn't do anything important, nobody 
is going to spend their time reviewing it.

I'm not going to continue this thread, the patch in question has been 
removed from -mm so I have no further interest in discussing it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
