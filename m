Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id AC61782F64
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 11:22:42 -0500 (EST)
Received: by igvi2 with SMTP id i2so51684655igv.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 08:22:42 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b5si17865130ioe.61.2015.11.02.08.22.42
        for <linux-mm@kvack.org>;
        Mon, 02 Nov 2015 08:22:42 -0800 (PST)
Date: Mon, 2 Nov 2015 16:22:37 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v6 2/3] percpu: add PERCPU_ATOM_SIZE for a generic percpu
 area setup
Message-ID: <20151102162236.GB7637@e104818-lin.cambridge.arm.com>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com>
 <1446363977-23656-3-git-send-email-jungseoklee85@gmail.com>
 <alpine.DEB.2.20.1511021008580.27740@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1511021008580.27740@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jungseok Lee <jungseoklee85@gmail.com>, mark.rutland@arm.com, takahiro.akashi@linaro.org, barami97@gmail.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, james.morse@arm.com, tj@kernel.org, linux-arm-kernel@lists.infradead.org

On Mon, Nov 02, 2015 at 10:10:23AM -0600, Christoph Lameter wrote:
> On Sun, 1 Nov 2015, Jungseok Lee wrote:
> 
> > There is no room to adjust 'atom_size' now when a generic percpu area
> > is used. It would be redundant to write down an architecture-specific
> > setup_per_cpu_areas() in order to only change the 'atom_size'. Thus,
> > this patch adds a new definition, PERCPU_ATOM_SIZE, which is PAGE_SIZE
> > by default. The value could be updated if needed by architecture.
> 
> What is atom_size? Why would you want a difference allocation size here?
> The percpu area is virtually mapped regardless. So you will have
> contiguous addresses even without atom_size.

I haven't looked at the patch 3/3 in detail but I'm pretty sure I'll NAK
the approach (and the definition of PERCPU_ATOM_SIZE), therefore
rendering this patch unnecessary. IIUC, this is used to enforce some
alignment of the per-CPU IRQ stack to be able to check whether the
current stack is process or IRQ on exception entry. But there are other,
less intrusive ways to achieve the same (e.g. x86).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
