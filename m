Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC59F6B0005
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 17:35:35 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id j3so4933689wrb.18
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 14:35:35 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id r67si3095814wma.264.2018.03.01.14.35.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 14:35:34 -0800 (PST)
Date: Thu, 1 Mar 2018 23:35:29 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 02/11] ACPI / APEI: Generalise the estatus queue's
 add/remove and notify code
Message-ID: <20180301223529.GA28811@pd.tnic>
References: <20180215185606.26736-1-james.morse@arm.com>
 <20180215185606.26736-3-james.morse@arm.com>
 <20180301150144.GA4215@pd.tnic>
 <87sh9jbrgc.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <87sh9jbrgc.fsf@e105922-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: James Morse <james.morse@arm.com>, linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>

On Thu, Mar 01, 2018 at 06:06:59PM +0000, Punit Agrawal wrote:
> You're looking at support for the 32-bit ARM systems.

I know. That's why I'm asking.

> The 64-bit support lives in arch/arm64 and the die() there doesn't
> contain an oops_begin()/oops_end(). But the lack of oops_begin() on
> arm64 doesn't really matter here.

Yap.

> One issue I see with calling die() is that it is defined in different
> includes across various architectures, (e.g., include/asm/kdebug.h for
> x86, include/asm/system_misc.h in arm64, etc.)

I don't think that's insurmountable.

The more important question is, can we do the same set of calls when
panic severity on all architectures which support APEI or should we have
arch-specific ghes_panic() callbacks or so.

As it is now, it would turn into a mess if we start with the ifdeffery
and the different requirements architectures might have...

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
