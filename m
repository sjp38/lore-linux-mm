Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id C22636B004D
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:50:21 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so1425458qcs.14
        for <linux-mm@kvack.org>; Thu, 28 Jun 2012 10:50:20 -0700 (PDT)
Date: Thu, 28 Jun 2012 13:50:16 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH] [RESEND] arm: limit memblock base address for
 early_pte_alloc
In-Reply-To: <20120628090827.GH19026@n2100.arm.linux.org.uk>
Message-ID: <alpine.LFD.2.02.1206281338170.31003@xanadu.home>
References: <1338880312-17561-1-git-send-email-minchan@kernel.org> <20120627161224.GB2310@linaro.org> <alpine.LFD.2.02.1206280019160.31003@xanadu.home> <20120628090827.GH19026@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Dave Martin <dave.martin@linaro.org>, Minchan Kim <minchan@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Chanho Min <chanho.min@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jongsung Kim <neidhard.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On Thu, 28 Jun 2012, Russell King - ARM Linux wrote:

> Err, I don't think you understand what's going on here.
> 
> The sequence is:
> 
> 1. setup the initial mappings so we can run the kernel in virtual space.
> 2. provide the memory areas to memblock
> 3. ask the platform to reserve whatever memory it wants from memblock
>    [this means using memblock_reserve or arm_memblock_steal).  The
>    reserved memory is *not* expected to be mapped at this point, and is
>    therefore inaccessible.
> 4. Setup the lowmem mappings.

I do understand that pretty well so far.

> And when we're setting up the lowmem mappings, we do *not* expect to
> create any non-section page mappings, which again means we have no reason
> to use the memblock allocator to obtain memory that we want to immediately
> use.

And why does this have to remain so?

> So I don't know where you're claim of being "fragile" is coming from.

It doesn't come from anything you've described so far. It comes from 
those previous attempts at lifting this limitation.  I think that my 
proposal is much less fragile than the other ones.

> What is fragile is people wanting to use arm_memblock_steal() without
> following the rules for it I layed down.

What about enhancing your rules if the technical limitations they were 
based on are lifted?


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
