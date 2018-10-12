Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id EE4876B0008
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 07:08:32 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id v30-v6so7595496wra.19
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 04:08:32 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id l73-v6si965195wmb.201.2018.10.12.04.08.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 04:08:31 -0700 (PDT)
Date: Fri, 12 Oct 2018 13:08:19 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 08/18] ACPI / APEI: Move locking to the notification
 helper
Message-ID: <20181012110819.GB580@zn.tnic>
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180921221705.6478-9-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180921221705.6478-9-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Fri, Sep 21, 2018 at 11:16:55PM +0100, James Morse wrote:
> ghes_copy_tofrom_phys() takes different locks depending on in_nmi().
> This doesn't work when we have multiple NMI-like notifications, that
> can interrupt each other.
> 
> Now that NOTIFY_SEA is always called as an NMI, move the lock-taking
> to the notification helper. The helper will always know which lock
> to take. This avoids ghes_copy_tofrom_phys() taking a guess based
> on in_nmi().
> 
> This splits NOTIFY_NMI and NOTIFY_SEA to use different locks. All
> the other notifications use ghes_proc(), and are called in process
> or IRQ context. Move the spin_lock_irqsave() around their ghes_proc()
> calls.

Right, should ghes_proc() be renamed to ghes_proc_irq() now, to be
absolutely clear on the processing context it is operating in?

Other than that:

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
