Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 174C36B7AD6
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 11:18:24 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id t83so420356oie.16
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 08:18:24 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e71si291850oic.46.2018.12.06.08.18.23
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 08:18:23 -0800 (PST)
Date: Thu, 6 Dec 2018 16:18:17 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v7 23/25] arm64: acpi: Make apei_claim_sea() synchronise
 with APEI's irq work
Message-ID: <20181206161817.GN54495@arrakis.emea.arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-24-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-24-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, Rafael Wysocki <rjw@rjwysocki.net>, Tony Luck <tony.luck@intel.com>, Fan Wu <wufan@codeaurora.org>, Xie XiuQi <xiexiuqi@huawei.com>, Marc Zyngier <marc.zyngier@arm.com>, Will Deacon <will.deacon@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Dongjiu Geng <gengdongjiu@huawei.com>, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, Len Brown <lenb@kernel.org>

On Mon, Dec 03, 2018 at 06:06:11PM +0000, James Morse wrote:
> APEI is unable to do all of its error handling work in nmi-context, so
> it defers non-fatal work onto the irq_work queue. arch_irq_work_raise()
> sends an IPI to the calling cpu, but this is not guaranteed to be taken
> before returning to user-space.
> 
> Unless the exception interrupted a context with irqs-masked,
> irq_work_run() can run immediately. Otherwise return -EINPROGRESS to
> indicate ghes_notify_sea() found some work to do, but it hasn't
> finished yet.
> 
> With this apei_claim_sea() returning '0' means this external-abort was
> also notification of a firmware-first RAS error, and that APEI has
> processed the CPER records.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
> Tested-by: Tyler Baicar <tbaicar@codeaurora.org>
> CC: Xie XiuQi <xiexiuqi@huawei.com>
> CC: gengdongjiu <gengdongjiu@huawei.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
