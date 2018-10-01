Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id F172B6B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 13:59:56 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id z9-v6so16930546wrv.6
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 10:59:56 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id k6-v6si10496181wri.426.2018.10.01.10.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 10:59:55 -0700 (PDT)
Date: Mon, 1 Oct 2018 19:59:56 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 05/18] ACPI / APEI: Make estatus queue a Kconfig symbol
Message-ID: <20181001175956.GF7269@zn.tnic>
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180921221705.6478-6-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180921221705.6478-6-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Fri, Sep 21, 2018 at 11:16:52PM +0100, James Morse wrote:
> Now that there are two users of the estatus queue, and likely to be more,
> make it a Kconfig symbol selected by the appropriate notification. We
> can move the ARCH_HAVE_NMI_SAFE_CMPXCHG checks in here too.

Ok, question: why do we need to complicate things at all? I mean, why do
we even need a Kconfig symbol?

This code is being used by two arches now so why not simply build it in
unconditionally and be done with it. The couple of KB saved are simply
not worth the effort, especially if it is going to end up being enabled
on 99% of the setups...

Or?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
