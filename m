Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 32DEA6B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 21:46:57 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id i8so6545581qcq.1
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 18:46:56 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id a6si3455019qcq.25.2015.02.11.18.46.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 11 Feb 2015 18:46:55 -0800 (PST)
Date: Wed, 11 Feb 2015 20:46:53 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] slub: Support for array operations
In-Reply-To: <20150212131649.59b70f71@redhat.com>
Message-ID: <alpine.DEB.2.11.1502112045540.21460@gentwo.org>
References: <20150210194804.288708936@linux.com> <20150210194811.902155759@linux.com> <20150211174817.44cc5562@redhat.com> <alpine.DEB.2.11.1502111305520.7547@gentwo.org> <20150212104316.2d5c32ea@redhat.com> <alpine.DEB.2.11.1502111604510.15061@gentwo.org>
 <20150212131649.59b70f71@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

On Thu, 12 Feb 2015, Jesper Dangaard Brouer wrote:

> Measured on my laptop CPU i7-2620M CPU @ 2.70GHz:
>
>  * 12.775 ns - "clean" spin_lock_unlock
>  * 21.099 ns - irqsave variant spinlock
>  * 22.808 ns - "manual" irqsave before spin_lock
>  * 14.618 ns - "manual" local_irq_disable + spin_lock
>
> Reproducible via my github repo:
>  https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench_sample.c
>
> The clean spin_lock_unlock is 8.324 ns faster than irqsave variant.
> The irqsave variant is actually faster than expected, as the measurement
> of an isolated local_irq_save_restore were 13.256 ns.

I am using spin_lock_irq() in the current version on my system. If the
performance of that is a problem then please optimize that function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
