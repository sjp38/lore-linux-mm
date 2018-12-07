Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD15A8E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 06:55:15 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id s140so1740696oih.4
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 03:55:15 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 80si400374otu.91.2018.12.07.03.55.13
        for <linux-mm@kvack.org>;
        Fri, 07 Dec 2018 03:55:13 -0800 (PST)
Date: Fri, 7 Dec 2018 11:55:09 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V5 6/7] arm64: mm: introduce 52-bit userspace support
Message-ID: <20181207115508.GC23085@arrakis.emea.arm.com>
References: <20181206225042.11548-1-steve.capper@arm.com>
 <20181206225042.11548-7-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181206225042.11548-7-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, ard.biesheuvel@linaro.org, suzuki.poulose@arm.com, will.deacon@arm.com, jcm@redhat.com

On Thu, Dec 06, 2018 at 10:50:41PM +0000, Steve Capper wrote:
> On arm64 there is optional support for a 52-bit virtual address space.
> To exploit this one has to be running with a 64KB page size and be
> running on hardware that supports this.
> 
> For an arm64 kernel supporting a 48 bit VA with a 64KB page size,
> some changes are needed to support a 52-bit userspace:
>  * TCR_EL1.T0SZ needs to be 12 instead of 16,
>  * TASK_SIZE needs to reflect the new size.
> 
> This patch implements the above when the support for 52-bit VAs is
> detected at early boot time.
> 
> On arm64 userspace addresses translation is controlled by TTBR0_EL1. As
> well as userspace, TTBR0_EL1 controls:
>  * The identity mapping,
>  * EFI runtime code.
> 
> It is possible to run a kernel with an identity mapping that has a
> larger VA size than userspace (and for this case __cpu_set_tcr_t0sz()
> would set TCR_EL1.T0SZ as appropriate). However, when the conditions for
> 52-bit userspace are met; it is possible to keep TCR_EL1.T0SZ fixed at
> 12. Thus in this patch, the TCR_EL1.T0SZ size changing logic is
> disabled.
> 
> Signed-off-by: Steve Capper <steve.capper@arm.com>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
