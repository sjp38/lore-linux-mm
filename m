Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC6C86B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 06:47:08 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u144so80011913wmu.1
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 03:47:08 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.74])
        by mx.google.com with ESMTPS id v77si16107278wmd.111.2016.11.08.03.47.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 03:47:07 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] mm: only enable sys_pkey* when ARCH_HAS_PKEYS
Date: Tue, 08 Nov 2016 12:39:28 +0100
Message-ID: <1596342.1rV5HksyDO@wuerfel>
In-Reply-To: <20161108093042.GC3528@osiris>
References: <1477958904-9903-1-git-send-email-mark.rutland@arm.com> <20161104234459.GA18760@remoulade> <20161108093042.GC3528@osiris>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Russell King <rmk+kernel@armlinux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On Tuesday, November 8, 2016 10:30:42 AM CET Heiko Carstens wrote:
> Three architectures (parisc, powerpc, s390) decided to ignore the system
> calls completely, but still have the pkey code linked into the kernel
> image.

Wouldn't it actually make sense to hook this up to the storage keys
in the s390 page tables?

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
