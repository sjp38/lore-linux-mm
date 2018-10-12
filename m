Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id E7A406B000E
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 07:14:10 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id j124-v6so6738113wmd.4
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 04:14:10 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id p184-v6si944826wmp.160.2018.10.12.04.14.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 04:14:09 -0700 (PDT)
Date: Fri, 12 Oct 2018 13:14:08 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 09/18] ACPI / APEI: Let the notification helper
 specify the fixmap slot
Message-ID: <20181012111408.GC580@zn.tnic>
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180921221705.6478-10-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180921221705.6478-10-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Fri, Sep 21, 2018 at 11:16:56PM +0100, James Morse wrote:
> ghes_copy_tofrom_phys() uses a different fixmap slot depending on in_nmi().
> This doesn't work when we have multiple NMI-like notifications, that
> can interrupt each other.
> 
> As with the locking, move the chosen fixmap_idx to the notification helper.
> This only matters for NMI-like notifications, anything calling
> ghes_proc() can use the IRQ fixmap slot as its already holding an irqsave
> spinlock.
> 
> This lets us collapse the ghes_ioremap_pfn_*() helpers.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
> 
> The fixmap-idx and vaddr are passed back to ghes_unmap()
> to allow ioremap() to be used in process context in the
> future.
> ---
>  drivers/acpi/apei/ghes.c | 76 ++++++++++++++--------------------------
>  1 file changed, 27 insertions(+), 49 deletions(-)

Nice.

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
