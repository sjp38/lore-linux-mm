Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 734576B0012
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 13:26:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v8so1112351wmv.1
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 10:26:06 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id 93si1300886wra.239.2018.03.27.10.26.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 10:26:04 -0700 (PDT)
Date: Tue, 27 Mar 2018 19:25:10 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 02/11] ACPI / APEI: Generalise the estatus queue's
 add/remove and notify code
Message-ID: <20180327172510.GB32184@pd.tnic>
References: <20180215185606.26736-1-james.morse@arm.com>
 <20180215185606.26736-3-james.morse@arm.com>
 <20180301150144.GA4215@pd.tnic>
 <87sh9jbrgc.fsf@e105922-lin.cambridge.arm.com>
 <20180301223529.GA28811@pd.tnic>
 <5AA02C26.10803@arm.com>
 <20180308104408.GB21166@pd.tnic>
 <5AAFC939.3010309@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5AAFC939.3010309@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>

Hi James,

On Mon, Mar 19, 2018 at 02:29:13PM +0000, James Morse wrote:
> I don't think the die_lock really helps here, do we really want to wait for a
> remote CPU to finish printing an OOPs about user-space's bad memory accesses,
> before we bring the machine down due to this system-wide fatal RAS error? The
> presence of firmware-first means we know this error, and any other oops are
> unrelated.

Hmm, now that you put it this way...

> I'd like to leave this under the x86-ifdef for now. For arm64 it would be an
> APEI specific arch hook to stop the arch code from printing some messages,

... I'm thinking we should ignore the whole serializing of oopses and
really dump that hw error ASAP. If it really is a fatal error, our main
and only goal is to get it out as fast as possible so that it has the
highest chance to appear on some screen or logging facility and thus the
system can be serviced successfully.

And the other oopses have lower prio.

Hmmm?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
