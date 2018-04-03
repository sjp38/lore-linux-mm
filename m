Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id E5FA66B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 07:30:57 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id l1-v6so11166287oth.18
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 04:30:57 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 111-v6si798570oty.240.2018.04.03.04.30.56
        for <linux-mm@kvack.org>;
        Tue, 03 Apr 2018 04:30:56 -0700 (PDT)
Subject: Re: [PATCH v3 2/6] Disable instrumentation for some code
References: <20180402120440.31900-1-liuwenliang@huawei.com>
 <20180402120440.31900-3-liuwenliang@huawei.com>
From: Marc Zyngier <marc.zyngier@arm.com>
Message-ID: <7837103a-bcf0-6b00-14d6-bd6b80649886@arm.com>
Date: Tue, 3 Apr 2018 12:30:42 +0100
MIME-Version: 1.0
In-Reply-To: <20180402120440.31900-3-liuwenliang@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abbott Liu <liuwenliang@huawei.com>, aryabinin@virtuozzo.com, dvyukov@google.com, corbet@lwn.net, linux@armlinux.org.uk, christoffer.dall@linaro.org, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, f.fainelli@gmail.com, akpm@linux-foundation.org, linux@rasmusvillemoes.dk, mawilcox@microsoft.com, pombredanne@nexb.com, ard.biesheuvel@linaro.org, vladimir.murzin@arm.com, alexander.levin@verizon.com, nicolas.pitre@linaro.org, tglx@linutronix.de, thgarnie@google.com, dhowells@redhat.com, keescook@chromium.org, arnd@arndb.de, geert@linux-m68k.org, tixy@linaro.org, julien.thierry@arm.com, mark.rutland@arm.com, james.morse@arm.com, zhichao.huang@linaro.org, jinb.park7@gmail.com, labbott@redhat.com, philip@cog.systems, grygorii.strashko@linaro.org, catalin.marinas@arm.com, opendmb@gmail.com, kirill.shutemov@linux.intel.com, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvmarm@lists.cs.columbia.edu, linux-mm@kvack.org

On 02/04/18 13:04, Abbott Liu wrote:
> From: Andrey Ryabinin <a.ryabinin@samsung.com>
> 
> Disable instrumentation for arch/arm/boot/compressed/*
> ,arch/arm/kvm/hyp/* and arch/arm/vdso/* because those
> code won't linkd with kernel image.
> 
> Disable kasan check in the function unwind_pop_register
> because it doesn't matter that kasan checks failed when
> unwind_pop_register read stack memory of task.
> 
> Reviewed-by: Russell King - ARM Linux <linux@armlinux.org.uk>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> Reviewed-by: Marc Zyngier <marc.zyngier@arm.com>

Just because I replied to this patch doesn't mean you can stick my
Reviewed-by tag on it. Please drop this tag until I explicitly say that
you can add it (see Documentation/process/submitting-patches.rst,
section 11).

Same goes for patch 1.

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...
