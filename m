Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 395976B000C
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:11:29 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id w4-v6so11678062ote.8
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:11:29 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 73si818457oii.428.2018.03.26.08.11.28
        for <linux-mm@kvack.org>;
        Mon, 26 Mar 2018 08:11:28 -0700 (PDT)
Subject: Re: [PATCH v2 04/11] KVM: arm/arm64: Add kvm_ras.h to collect kvm
 specific RAS plumbing
References: <20180322181445.23298-1-james.morse@arm.com>
 <20180322181445.23298-5-james.morse@arm.com>
From: Marc Zyngier <marc.zyngier@arm.com>
Message-ID: <790d3e45-26c2-6095-7adf-1d59fda4541e@arm.com>
Date: Mon, 26 Mar 2018 16:11:22 +0100
MIME-Version: 1.0
In-Reply-To: <20180322181445.23298-5-james.morse@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>, linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>

On 22/03/18 18:14, James Morse wrote:
> To split up APEIs in_nmi() path, we need any nmi-like callers to always
> be in_nmi(). KVM shouldn't have to know about this, pull the RAS plumbing
> out into a header file.
> 
> Currently guest synchronous external aborts are claimed as RAS
> notifications by handle_guest_sea(), which is hidden in the arch codes
> mm/fault.c. 32bit gets a dummy declaration in system_misc.h.
> 
> There is going to be more of this in the future if/when we support
> the SError-based firmware-first notification mechanism and/or
> kernel-first notifications for both synchronous external abort and
> SError. Each of these will come with some Kconfig symbols and a
> handful of header files.
> 
> Create a header file for all this.
> 
> This patch gives handle_guest_sea() a 'kvm_' prefix, and moves the
> declarations to kvm_ras.h as preparation for a future patch that moves
> the ACPI-specific RAS code out of mm/fault.c.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>

Acked-by: Marc Zyngier <marc.zyngier@arm.com>

	M.
-- 
Jazz is not dead. It just smells funny...
