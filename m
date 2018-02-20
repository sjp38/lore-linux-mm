Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 476A56B0005
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 14:29:05 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o23so1582851wrc.9
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:29:05 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id p7si4511044wrd.281.2018.02.20.11.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 11:29:03 -0800 (PST)
Date: Tue, 20 Feb 2018 20:28:52 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 01/11] ACPI / APEI: Move the estatus queue code up, and
 under its own ifdef
Message-ID: <20180220192852.GB24320@pd.tnic>
References: <20180215185606.26736-1-james.morse@arm.com>
 <20180215185606.26736-2-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180215185606.26736-2-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>

On Thu, Feb 15, 2018 at 06:55:56PM +0000, James Morse wrote:
> +#ifdef CONFIG_HAVE_ACPI_APEI_NMI
> +/*
> + * While printk() now has an in_nmi() path, the handling for CPER records
> + * does not. For example, memory_failure_queue() takes spinlocks and calls
> + * schedule_work_on().
> + *
> + * So in any NMI-like handler, we allocate required memory from lock-less
> + * memory allocator (ghes_estatus_pool), save estatus into it, put them into
> + * lock-less list (ghes_estatus_llist), then delay printk into IRQ context via
> + * irq_work (ghes_proc_irq_work).  ghes_estatus_size_request record
> + * required pool size by all NMI error source.

Since you're touching this, pls correct the grammar too, while at it,
and correct them into proper sentences. Also, end function names with
"()". Also the "we" pronoun and tense sounds funny - let's make it
passive.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
