Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1706B000A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 13:34:24 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id f13-v6so9128006wrr.4
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 10:34:24 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id z14-v6si4099095wrl.151.2018.10.04.10.34.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 10:34:23 -0700 (PDT)
Date: Thu, 4 Oct 2018 19:34:16 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 05/18] ACPI / APEI: Make estatus queue a Kconfig symbol
Message-ID: <20181004173416.GC5149@zn.tnic>
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180921221705.6478-6-james.morse@arm.com>
 <20181001175956.GF7269@zn.tnic>
 <a562d7c4-2e74-3a18-7fb0-ba8f40d2dce4@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <a562d7c4-2e74-3a18-7fb0-ba8f40d2dce4@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Wed, Oct 03, 2018 at 06:50:36PM +0100, James Morse wrote:
> I'm all in favour of letting the compiler work it out, but the existing ghes
> code has #ifdef/#else all over the place. This is 'keeping the style'.

Yeah, but this "style" is not the optimal one and we should
simplify/clean up and fix this thing.

Swapping the order of your statements here:

> The ACPI spec has four ~NMI notifications, so far the support for
> these in Linux has been selectable separately.

Yes, but: distro kernels end up enabling all those options anyway and
distro kernels are 90-ish% of the setups. Which means, this will get
enabled anyway and this additional Kconfig symbol is simply going to be
one automatic reply "Yes".

So let's build it in by default and if someone complains about it, we
can always carve it out. But right now I don't see the need for the
unnecessary separation...

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
