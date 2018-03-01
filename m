Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8602F6B000D
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 10:02:00 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id d18so4325846wre.6
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 07:02:00 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id z84si2705575wmc.68.2018.03.01.07.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 07:01:48 -0800 (PST)
Date: Thu, 1 Mar 2018 16:01:44 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 02/11] ACPI / APEI: Generalise the estatus queue's
 add/remove and notify code
Message-ID: <20180301150144.GA4215@pd.tnic>
References: <20180215185606.26736-1-james.morse@arm.com>
 <20180215185606.26736-3-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180215185606.26736-3-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>

On Thu, Feb 15, 2018 at 06:55:57PM +0000, James Morse wrote:
> Keep the oops_begin() call for x86,

That oops_begin() in generic code is such a layering violation, grrr.

> arm64 doesn't have one of these,
> and APEI is the only thing outside arch code calling this..

So looking at:

arch/arm/kernel/traps.c:die()

it does call oops_begin() ... oops_end() just like the x86 version of
die().

I'm wondering if we could move the code to do die() in a prepatch? My
assumption is that all the arches should have die()... A quick grep does
show a bunch of other arches having die()...

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
