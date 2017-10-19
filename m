Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D35926B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:47:56 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y10so3522833wmd.4
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:47:56 -0700 (PDT)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id t144si1110078wmt.249.2017.10.19.05.47.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 05:47:55 -0700 (PDT)
Date: Thu, 19 Oct 2017 13:47:15 +0100
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 05/11] Disable kasan's instrumentation
Message-ID: <20171019124714.GZ20805@n2100.armlinux.org.uk>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-6-liuwenliang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171011082227.20546-6-liuwenliang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abbott Liu <liuwenliang@huawei.com>
Cc: aryabinin@virtuozzo.com, afzal.mohd.ma@gmail.com, f.fainelli@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, glider@google.com, dvyukov@google.com, opendmb@gmail.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

On Wed, Oct 11, 2017 at 04:22:21PM +0800, Abbott Liu wrote:
> From: Andrey Ryabinin <a.ryabinin@samsung.com>
> 
>  To avoid some build and runtime errors, compiler's instrumentation must
>  be disabled for code not linked with kernel image.

How does that explain the change to unwind.c ?

Does this also disable the string macro changes?

In any case, this should certainly precede patch 4, and very probably
patch 2.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
