Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0D38E6B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 13:31:16 -0500 (EST)
Received: by padec8 with SMTP id ec8so46612244pad.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 10:31:15 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id kx3si23347842pbc.73.2015.11.02.10.31.15
        for <linux-mm@kvack.org>;
        Mon, 02 Nov 2015 10:31:15 -0800 (PST)
Date: Mon, 2 Nov 2015 18:31:10 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v6 2/3] percpu: add PERCPU_ATOM_SIZE for a generic percpu
 area setup
Message-ID: <20151102183110.GD7637@e104818-lin.cambridge.arm.com>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com>
 <1446363977-23656-3-git-send-email-jungseoklee85@gmail.com>
 <alpine.DEB.2.20.1511021008580.27740@east.gentwo.org>
 <20151102162236.GB7637@e104818-lin.cambridge.arm.com>
 <alpine.DEB.2.20.1511021047420.28255@east.gentwo.org>
 <20151102173520.GC7637@e104818-lin.cambridge.arm.com>
 <alpine.DEB.2.20.1511021210250.28799@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1511021210250.28799@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: mark.rutland@arm.com, Jungseok Lee <jungseoklee85@gmail.com>, takahiro.akashi@linaro.org, barami97@gmail.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, james.morse@arm.com, tj@kernel.org, linux-arm-kernel@lists.infradead.org

On Mon, Nov 02, 2015 at 12:11:33PM -0600, Christoph Lameter wrote:
> On Mon, 2 Nov 2015, Catalin Marinas wrote:
> 
> > On Mon, Nov 02, 2015 at 10:48:17AM -0600, Christoph Lameter wrote:
> > > On Mon, 2 Nov 2015, Catalin Marinas wrote:
> > > > I haven't looked at the patch 3/3 in detail but I'm pretty sure I'll NAK
> > > > the approach (and the definition of PERCPU_ATOM_SIZE), therefore
> > > > rendering this patch unnecessary. IIUC, this is used to enforce some
> > > > alignment of the per-CPU IRQ stack to be able to check whether the
> > > > current stack is process or IRQ on exception entry. But there are other,
> > > > less intrusive ways to achieve the same (e.g. x86).
> > >
> > > The percpu allocator allows the specification of alignment requirements.
> >
> > Patch 3/3 does something like this:
> >
> > DEFINE_PER_CPU(char [IRQ_STACK_SIZE], irq_stacks) __aligned(IRQ_STACK_SIZE)
> >
> > where IRQ_STACK_SIZE > PAGE_SIZE. AFAICT, setup_per_cpu_areas() doesn't
> > guarantee alignment greater than PAGE_SIZE.
> 
> And we cannot use percpu_alloc() instead? Aligning the whole of the percpu
> area because one allocation requires it?

I haven't tried but it seems that pcpu_alloc() has a WARN() when align >
PAGE_SIZE and it would fail.

As I said in a previous reply, I don't think this patch is necessary,
mainly because I don't particularly like the logic for detecting the IRQ
stack re-entrance based on the stack pointer alignment.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
