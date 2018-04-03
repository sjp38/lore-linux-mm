Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADAD16B0007
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 07:39:27 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b17so9428112wrf.20
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 04:39:27 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id c48si1946999wrg.151.2018.04.03.04.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 04:39:26 -0700 (PDT)
Date: Tue, 3 Apr 2018 12:38:37 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v3 2/6] Disable instrumentation for some code
Message-ID: <20180403113837.GK16141@n2100.armlinux.org.uk>
References: <20180402120440.31900-1-liuwenliang@huawei.com>
 <20180402120440.31900-3-liuwenliang@huawei.com>
 <7837103a-bcf0-6b00-14d6-bd6b80649886@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7837103a-bcf0-6b00-14d6-bd6b80649886@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Zyngier <marc.zyngier@arm.com>
Cc: Abbott Liu <liuwenliang@huawei.com>, aryabinin@virtuozzo.com, dvyukov@google.com, corbet@lwn.net, christoffer.dall@linaro.org, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, f.fainelli@gmail.com, akpm@linux-foundation.org, linux@rasmusvillemoes.dk, mawilcox@microsoft.com, pombredanne@nexb.com, ard.biesheuvel@linaro.org, vladimir.murzin@arm.com, alexander.levin@verizon.com, nicolas.pitre@linaro.org, tglx@linutronix.de, thgarnie@google.com, dhowells@redhat.com, keescook@chromium.org, arnd@arndb.de, geert@linux-m68k.org, tixy@linaro.org, julien.thierry@arm.com, mark.rutland@arm.com, james.morse@arm.com, zhichao.huang@linaro.org, jinb.park7@gmail.com, labbott@redhat.com, philip@cog.systems, grygorii.strashko@linaro.org, catalin.marinas@arm.com, opendmb@gmail.com, kirill.shutemov@linux.intel.com, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvmarm@lists.cs.columbia.edu, linux-mm@kvack.org

On Tue, Apr 03, 2018 at 12:30:42PM +0100, Marc Zyngier wrote:
> On 02/04/18 13:04, Abbott Liu wrote:
> > From: Andrey Ryabinin <a.ryabinin@samsung.com>
> > 
> > Disable instrumentation for arch/arm/boot/compressed/*
> > ,arch/arm/kvm/hyp/* and arch/arm/vdso/* because those
> > code won't linkd with kernel image.
> > 
> > Disable kasan check in the function unwind_pop_register
> > because it doesn't matter that kasan checks failed when
> > unwind_pop_register read stack memory of task.
> > 
> > Reviewed-by: Russell King - ARM Linux <linux@armlinux.org.uk>
> > Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> > Reviewed-by: Marc Zyngier <marc.zyngier@arm.com>
> 
> Just because I replied to this patch doesn't mean you can stick my
> Reviewed-by tag on it. Please drop this tag until I explicitly say that
> you can add it (see Documentation/process/submitting-patches.rst,
> section 11).
> 
> Same goes for patch 1.

Same goes for that reviewed-by line for me.  From my records, I never
even looked at patch 2 from the first posting, and I don't appear to
have the second posting in my mailbox (it's probably been classed as
spam by dspam.)  So these reviewed-by lines seem to be totally
misleading.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
