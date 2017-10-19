Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6FFAD6B0268
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:35:32 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id h191so3485940wmd.15
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:35:32 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id 140si1108202wmp.197.2017.10.19.05.35.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 05:35:31 -0700 (PDT)
Date: Thu, 19 Oct 2017 13:34:53 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 03/11] arm: Kconfig: enable KASan
Message-ID: <20171019123453.GV20805@n2100.armlinux.org.uk>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-4-liuwenliang@huawei.com>
 <a3902e32-0141-9616-ba3e-9cbbd396b99a@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a3902e32-0141-9616-ba3e-9cbbd396b99a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: Abbott Liu <liuwenliang@huawei.com>, aryabinin@virtuozzo.com, afzal.mohd.ma@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org, opendmb@gmail.com, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, zengweilin@huawei.com, linux-mm@kvack.org, dylix.dailei@huawei.com, glider@google.com, dvyukov@google.com, jiazhenghua@huawei.com, linux-arm-kernel@lists.infradead.org, heshaoliang@huawei.com

On Wed, Oct 11, 2017 at 12:15:44PM -0700, Florian Fainelli wrote:
> On 10/11/2017 01:22 AM, Abbott Liu wrote:
> > From: Andrey Ryabinin <a.ryabinin@samsung.com>
> > 
> > This patch enable kernel address sanitizer for arm.
> > 
> > Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
> > Signed-off-by: Abbott Liu <liuwenliang@huawei.com>
> 
> This needs to be the last patch in the series, otherwise you allow
> people between patch 3 and 11 to have varying degrees of experience with
> this patch series depending on their system type (LPAE or not, etc.)

As the series stands, if patches 1-3 are applied, and KASAN is enabled,
there are various constants that end up being undefined, and the kernel
build will fail.  That is, of course, not acceptable.

KASAN must not be available until support for it is functionally
complete.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
