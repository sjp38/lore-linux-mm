Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 361E26B01AF
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 19:54:00 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o5QNrvkH025293
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:53:57 -0700
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by hpaq13.eem.corp.google.com with ESMTP id o5QNrt2g003366
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:53:56 -0700
Received: by pxi1 with SMTP id 1so2352142pxi.15
        for <linux-mm@kvack.org>; Sat, 26 Jun 2010 16:53:55 -0700 (PDT)
Date: Sat, 26 Jun 2010 16:53:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q 09/16] [percpu] make allocpercpu usable during early boot
In-Reply-To: <4C25B610.1050305@kernel.org>
Message-ID: <alpine.DEB.2.00.1006261652440.27174@chino.kir.corp.google.com>
References: <20100625212026.810557229@quilx.com> <20100625212106.384650677@quilx.com> <4C25B610.1050305@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sat, 26 Jun 2010, Tejun Heo wrote:

> On 06/25/2010 11:20 PM, Christoph Lameter wrote:
> > allocpercpu() may be used during early boot after the page allocator
> > has been bootstrapped but when interrupts are still off. Make sure
> > that we do not do GFP_KERNEL allocations if this occurs.
> > 
> > Cc: tj@kernel.org
> > Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> Acked-by: Tejun Heo <tj@kernel.org>
> 
> Christoph, how do you wanna route these patches?  I already have the
> other two patches in the percpu tree, I can push this there too, which
> then you can pull into the allocator tree.
> 

I think that's great for patches 2 and 3 in this series, but this patch is 
only a bandaid for allocations done in early boot whereas the real fix 
should be within a lower layer such as the slab or page allocator since 
the irq context on the boot cpu is not specific only to percpu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
