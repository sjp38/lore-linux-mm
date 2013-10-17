Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2029A6B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 21:17:07 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so1516658pad.16
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 18:17:06 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so1548322pab.22
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 18:17:04 -0700 (PDT)
Date: Wed, 16 Oct 2013 18:17:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/readahead.c: need always return 0 when system call
 readahead() succeeds
In-Reply-To: <525F35F7.4070202@asianux.com>
Message-ID: <alpine.DEB.2.02.1310161812480.12062@chino.kir.corp.google.com>
References: <5212E328.40804@asianux.com> <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org> <521428D0.2020708@asianux.com> <20130917155644.cc988e7e929fee10e9c86d86@linux-foundation.org> <52390907.7050101@asianux.com> <525CF787.6050107@asianux.com>
 <alpine.DEB.2.02.1310161603280.2417@chino.kir.corp.google.com> <525F35F7.4070202@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com, linux-mm@kvack.org

On Thu, 17 Oct 2013, Chen Gang wrote:

> If possible, you can help me check all my patches again (at least, it is
> not a bad idea to me).  ;-)
> 

I think your patches should be acked before being merged into linux-next, 
Hugh just had to revert another one that did affect Linus's tree in 
1ecfd533f4c5 ("mm/mremap.c: call pud_free() after fail calling
pmd_alloc()").  I had to revert your entire series of mpol_to_str() 
changes in -mm.  It's getting ridiculous and a waste of other people's 
time.

> > Nack to this and nack to the problem patch, which is absolutely pointless 
> > and did nothing but introduce this error.  readahead() is supposed to 
> > return 0, -EINVAL, or -EBADF and your original patch broke it.  That's 
> > because your original patch was completely pointless to begin with.
> > 
> 
> Do you mean: in do_readahead(), we need not check the return value of
> force_page_cache_readahead()?
> 

I'm saying we should revert 
mm-readaheadc-return-the-value-which-force_page_cache_readahead-returns.patch 
which violates the API of a syscall.  I see that patch has since been 
removed from -mm, so I'm happy with the result.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
