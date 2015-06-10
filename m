Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 98F2C6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 13:25:04 -0400 (EDT)
Received: by wigg3 with SMTP id g3so55776252wig.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 10:25:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id df4si10988810wib.111.2015.06.10.10.25.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 10:25:02 -0700 (PDT)
Date: Wed, 10 Jun 2015 18:24:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150610172457.GH26425@suse.de>
References: <20150609103231.GA11026@gmail.com>
 <20150609112055.GS26425@suse.de>
 <20150609124328.GA23066@gmail.com>
 <5577078B.2000503@intel.com>
 <55771909.2020005@intel.com>
 <55775749.3090004@intel.com>
 <CA+55aFz6b5pG9tRNazk8ynTCXS3whzWJ_737dt1xxAHDf1jASQ@mail.gmail.com>
 <20150610131354.GO19417@two.firstfloor.org>
 <CA+55aFwVUkdaf0_rBk7uJHQjWXu+OcLTHc6FKuCn0Cb2Kvg9NA@mail.gmail.com>
 <CA+55aFxhfkBDqVo+-rRHgkA4os7GkApvjNXW5SWXH03MW8Vw5A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFxhfkBDqVo+-rRHgkA4os7GkApvjNXW5SWXH03MW8Vw5A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Jun 10, 2015 at 09:42:34AM -0700, Linus Torvalds wrote:
> On Wed, Jun 10, 2015 at 9:17 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > So anyway, I like the patch series. I just think that the final patch
> > - the one that actually saves the addreses, and limits things to
> > BATCH_TLBFLUSH_SIZE, should be limited.
> 
> Oh, and another thing:
> 
> Mel, can you please make that "struct tlbflush_unmap_batch" be just
> part of "struct task_struct" rather than a pointer?
> 

Yes, that was done earlier today based on Ingo's review so that the
allocation could be dealt with as a separate path at the end of the series.

> If you are worried about the cpumask size, you could use
> 
>       cpumask_var_t cpumask;
> 
> and
> 
>         alloc_cpumask_var(..)
> ...
>         free_cpumask_var(..)
> 
> for that.
> 
> That way, sane configurations never have the allocation cost.
> 

Ok, good point.  Patch 3 in my git tree ("mm: Dynamically allocate TLB
batch unmap control structure") does not do this but I'll look into doing
it before the release based on 4.2-rc1.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
