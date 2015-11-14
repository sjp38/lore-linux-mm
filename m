Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1496B0038
	for <linux-mm@kvack.org>; Sat, 14 Nov 2015 03:23:28 -0500 (EST)
Received: by padhx2 with SMTP id hx2so123225554pad.1
        for <linux-mm@kvack.org>; Sat, 14 Nov 2015 00:23:28 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id sc1si33541849pbb.21.2015.11.14.00.23.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 Nov 2015 00:23:27 -0800 (PST)
Subject: Re: Memory exhaustion testing?
References: <20151112215531.69ccec19@redhat.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <5646EF73.5010005@I-love.SAKURA.ne.jp>
Date: Sat, 14 Nov 2015 17:23:15 +0900
MIME-Version: 1.0
In-Reply-To: <20151112215531.69ccec19@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm <linux-mm@kvack.org>

On 2015/11/13 5:55, Jesper Dangaard Brouer wrote:
> Hi MM-people,
>
> How do you/we test the error paths when the system runs out of memory?
>
> What kind of tools do you use?
> or Any tricks to provoke this?

I use SystemTap for injecting memory allocation failure.

http://lkml.kernel.org/r/201503182136.EJC90660.QSFOVJFOLHFOtM@I-love.SAKURA.ne.jp

>
> For testing my recent change to the SLUB allocator, I've implemented a
> crude kernel module that tries to allocate all memory, so I can test the
> error code-path in kmem_cache_alloc_bulk.
>
> see:
>   https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test04_exhaust_mem.c
>

I think you can test the error code-path in kmem_cache_alloc_bulk as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
