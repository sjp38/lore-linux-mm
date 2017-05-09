Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0012831FD
	for <linux-mm@kvack.org>; Tue,  9 May 2017 19:24:51 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z88so3890425wrc.9
        for <linux-mm@kvack.org>; Tue, 09 May 2017 16:24:51 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id i186si2469026wme.133.2017.05.09.16.24.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 16:24:50 -0700 (PDT)
Date: Wed, 10 May 2017 00:24:34 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v3 2/3] ARM: Silence first allocation with
 CONFIG_ARM_MODULE_PLTS=y
Message-ID: <20170509232433.GM22219@n2100.armlinux.org.uk>
References: <20170427181902.28829-1-f.fainelli@gmail.com>
 <20170427181902.28829-3-f.fainelli@gmail.com>
 <fccefcb2-b711-0589-168a-714e55064279@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fccefcb2-b711-0589-168a-714e55064279@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

On Tue, May 09, 2017 at 04:16:09PM -0700, Florian Fainelli wrote:
> On 04/27/2017 11:19 AM, Florian Fainelli wrote:
> > When CONFIG_ARM_MODULE_PLTS is enabled, the first allocation using the
> > module space fails, because the module is too big, and then the module
> > allocation is attempted from vmalloc space. Silence the first allocation
> > failure in that case by setting __GFP_NOWARN.
> 
> Russell, are you okay with this change? Do you have a preference as
> which tree should carry this patch series?

It looks sensible.

Acked-by: Russell King <rmk+kernel@armlinux.org.uk>

No preference which tree it goes through...

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
