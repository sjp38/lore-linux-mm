Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id D6F726B0253
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 13:11:34 -0500 (EST)
Received: by igbdj2 with SMTP id dj2so59387260igb.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 10:11:34 -0800 (PST)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id 143si12871236ioe.192.2015.11.02.10.11.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 02 Nov 2015 10:11:34 -0800 (PST)
Date: Mon, 2 Nov 2015 12:11:33 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v6 2/3] percpu: add PERCPU_ATOM_SIZE for a generic percpu
 area setup
In-Reply-To: <20151102173520.GC7637@e104818-lin.cambridge.arm.com>
Message-ID: <alpine.DEB.2.20.1511021210250.28799@east.gentwo.org>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com> <1446363977-23656-3-git-send-email-jungseoklee85@gmail.com> <alpine.DEB.2.20.1511021008580.27740@east.gentwo.org> <20151102162236.GB7637@e104818-lin.cambridge.arm.com>
 <alpine.DEB.2.20.1511021047420.28255@east.gentwo.org> <20151102173520.GC7637@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: mark.rutland@arm.com, Jungseok Lee <jungseoklee85@gmail.com>, linux-mm@kvack.org, barami97@gmail.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, takahiro.akashi@linaro.org, james.morse@arm.com, tj@kernel.org, linux-arm-kernel@lists.infradead.org

On Mon, 2 Nov 2015, Catalin Marinas wrote:

> On Mon, Nov 02, 2015 at 10:48:17AM -0600, Christoph Lameter wrote:
> > On Mon, 2 Nov 2015, Catalin Marinas wrote:
> > > I haven't looked at the patch 3/3 in detail but I'm pretty sure I'll NAK
> > > the approach (and the definition of PERCPU_ATOM_SIZE), therefore
> > > rendering this patch unnecessary. IIUC, this is used to enforce some
> > > alignment of the per-CPU IRQ stack to be able to check whether the
> > > current stack is process or IRQ on exception entry. But there are other,
> > > less intrusive ways to achieve the same (e.g. x86).
> >
> > The percpu allocator allows the specification of alignment requirements.
>
> Patch 3/3 does something like this:
>
> DEFINE_PER_CPU(char [IRQ_STACK_SIZE], irq_stacks) __aligned(IRQ_STACK_SIZE)
>
> where IRQ_STACK_SIZE > PAGE_SIZE. AFAICT, setup_per_cpu_areas() doesn't
> guarantee alignment greater than PAGE_SIZE.

And we cannot use percpu_alloc() instead? Aligning the whole of the percpu
area because one allocation requires it?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
