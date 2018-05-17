Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 175826B04EC
	for <linux-mm@kvack.org>; Thu, 17 May 2018 09:39:57 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id c56-v6so3128332wrc.5
        for <linux-mm@kvack.org>; Thu, 17 May 2018 06:39:57 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id 67-v6si4819179wrk.312.2018.05.17.06.39.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 06:39:56 -0700 (PDT)
Date: Thu, 17 May 2018 15:39:24 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 07/12] ACPI / APEI: Make the nmi_fixmap_idx per-ghes
 to allow multiple in_nmi() users
Message-ID: <20180517133924.GB27738@pd.tnic>
References: <20180427153510.5799-1-james.morse@arm.com>
 <20180427153510.5799-8-james.morse@arm.com>
 <20180505122719.GE3708@pd.tnic>
 <1511cfcc-dcd1-b3c5-01c7-6b6b8fb65b05@arm.com>
 <20180516110348.GA17092@pd.tnic>
 <39bde8c5-4dfb-c1b9-02a4-ba467539ea24@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <39bde8c5-4dfb-c1b9-02a4-ba467539ea24@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tyler Baicar <tbaicar@codeaurora.org>
Cc: James Morse <james.morse@arm.com>, linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, Thomas Gleixner <tglx@linutronix.de>

On Wed, May 16, 2018 at 11:38:16AM -0400, Tyler Baicar wrote:
> I haven't seen a deadlock from that, but it looks possible. What if
> the ghes_proc() call in ghes_probe() is moved before the second switch
> statement? That way it is before the NMI/IRQ/poll is setup. At quick
> glance I think that should avoid the deadlock and still provide the
> functionality that call was added for. I can test that out if you all
> agree.

Makes sense but please audit it properly before doing the change. That
code is full of landmines and could use a proper scrubbing first.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
