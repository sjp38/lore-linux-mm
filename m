Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9209E6B0023
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:36:20 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id l67-v6so1604291oif.23
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:36:20 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u145-v6si1163778oif.156.2018.03.28.09.36.19
        for <linux-mm@kvack.org>;
        Wed, 28 Mar 2018 09:36:19 -0700 (PDT)
Subject: Re: [PATCH v2 08/11] firmware: arm_sdei: Add ACPI GHES registration
 helper
References: <20180322181445.23298-9-james.morse@arm.com>
 <201803250913.XCBc2k7m%fengguang.wu@intel.com>
From: James Morse <james.morse@arm.com>
Message-ID: <590e2665-4471-8795-675e-28d103e1a103@arm.com>
Date: Wed, 28 Mar 2018 17:33:30 +0100
MIME-Version: 1.0
In-Reply-To: <201803250913.XCBc2k7m%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>

Hi kbuild test robot,

On 25/03/18 02:41, kbuild test robot wrote:
> I love your patch! Yet something to improve:
> 
> [auto build test ERROR on pm/linux-next]
> [also build test ERROR on v4.16-rc6]
> [cannot apply to arm64/for-next/core next-20180323]

This is the potential conflict I referred to in v1's cover letter...


> All errors (new ones prefixed by >>):
> 
>    drivers//firmware/arm_sdei.c: In function 'sdei_register_ghes':
>>> drivers//firmware/arm_sdei.c:921:26: error: 'FIX_APEI_GHES_SDEI_CRITICAL' undeclared (first use in this function)
>       ghes->nmi_fixmap_idx = FIX_APEI_GHES_SDEI_CRITICAL;

Looks like I forgot to include asm/fixmap.h! I hate header-soup.


Thanks,

James
