Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C4A926B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 03:35:09 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so3020014pdj.27
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 00:35:09 -0700 (PDT)
Received: from homiemail-a5.g.dreamhost.com (homie.mail.dreamhost.com. [208.97.132.208])
        by mx.google.com with ESMTP id bc3si13380260pbb.199.2014.10.22.00.35.06
        for <linux-mm@kvack.org>;
        Wed, 22 Oct 2014 00:35:08 -0700 (PDT)
Message-ID: <1413963289.26628.3.camel@linux-t7sj.site>
Subject: Re: [RFC][PATCH 0/6] Another go at speculative page faults
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 22 Oct 2014 00:34:49 -0700
In-Reply-To: <20141020215633.717315139@infradead.org>
References: <20141020215633.717315139@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2014-10-20 at 23:56 +0200, Peter Zijlstra wrote:
> Hi,
> 
> I figured I'd give my 2010 speculative fault series another spin:
> 
>   https://lkml.org/lkml/2010/1/4/257
> 
> Since then I think many of the outstanding issues have changed sufficiently to
> warrant another go. In particular Al Viro's delayed fput seems to have made it
> entirely 'normal' to delay fput(). Lai Jiangshan's SRCU rewrite provided us
> with call_srcu() and my preemptible mmu_gather removed the TLB flushes from
> under the PTL.
> 
> The code needs way more attention but builds a kernel and runs the
> micro-benchmark so I figured I'd post it before sinking more time into it.
> 
> I realize the micro-bench is about as good as it gets for this series and not
> very realistic otherwise, but I think it does show the potential benefit the
> approach has.
> 
> (patches go against .18-rc1+)

I think patch 2/6 is borken:

error: patch failed: mm/memory.c:2025
error: mm/memory.c: patch does not apply

and related, as you mention, I would very much welcome having the
introduction of 'struct faut_env' as a separate cleanup patch. May I
suggest renaming it to fault_cxt?

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
