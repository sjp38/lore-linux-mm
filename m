Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 366086B0255
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 09:43:37 -0500 (EST)
Received: by ykdr82 with SMTP id r82so241211447ykd.3
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 06:43:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y136si23505687ywd.16.2015.11.16.06.43.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 06:43:36 -0800 (PST)
Date: Mon, 16 Nov 2015 15:43:32 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Memory exhaustion testing?
Message-ID: <20151116154332.3f8fd151@redhat.com>
In-Reply-To: <5646EF73.5010005@I-love.SAKURA.ne.jp>
References: <20151112215531.69ccec19@redhat.com>
	<5646EF73.5010005@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm <linux-mm@kvack.org>, brouer@redhat.com

On Sat, 14 Nov 2015 17:23:15 +0900
Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> On 2015/11/13 5:55, Jesper Dangaard Brouer wrote:
> > Hi MM-people,
> >
> > How do you/we test the error paths when the system runs out of memory?
> >
> > What kind of tools do you use?
> > or Any tricks to provoke this?
> 
> I use SystemTap for injecting memory allocation failure.
> 
> http://lkml.kernel.org/r/201503182136.EJC90660.QSFOVJFOLHFOtM@I-love.SAKURA.ne.jp
> 
> >
> > For testing my recent change to the SLUB allocator, I've implemented a
> > crude kernel module that tries to allocate all memory, so I can test the
> > error code-path in kmem_cache_alloc_bulk.
> >
> > see:
> >   https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test04_exhaust_mem.c
> >
> 
> I think you can test the error code-path in kmem_cache_alloc_bulk as
> well.

Yes, making __alloc_pages_nodemask() fail should propagate all the way
back into kmem_cache_alloc_bulk().

I do like your approach, but I think my use-case can be covered by
CONFIG_FAIL_PAGE_ALLOC (which like you, also hook into __alloc_pages_nodemask).
Although it seems I have more control with your approach, to filter in
which situations it should happen in.

Thanks for your input! :-)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
