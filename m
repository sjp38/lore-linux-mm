Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id C6F426B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:38:56 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id k206so27621558oia.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 06:38:56 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id z186si10495427oig.87.2016.01.28.06.38.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 06:38:55 -0800 (PST)
Date: Thu, 28 Jan 2016 06:38:52 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: mm: provide reference to READ_IMPLIES_EXEC
Message-ID: <20160128143852.GA22099@roeck-us.net>
References: <1453972263-25907-1-git-send-email-sudipm.mukherjee@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453972263-25907-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <koct9i@gmail.com>

On Thu, Jan 28, 2016 at 02:41:03PM +0530, Sudip Mukherjee wrote:
> blackfin defconfig fails with the error:
> mm/internal.h: In function 'is_stack_mapping':
> arch/blackfin/include/asm/page.h:15:27: error: 'READ_IMPLIES_EXEC' undeclared
> 
> Commit 07dff8ae2bc5 has added is_stack_mapping in mm/internal.h but it
> also needs personality.h.
> 
> Fixes: 07dff8ae2bc5 ("mm: warn about VmData over RLIMIT_DATA")

FWIW, this is just one of many build failures due to this patch.
Pretty much all non-MMU builds fail, plus several MMU builds.
I had prepared a patch for mn10300, but gave up after I noticed
all the other failures.

Build results in next-20160128:
	total: 146 pass: 121 fail: 25
Failed builds:
	alpha:allmodconfig
	arm64:allnoconfig
	arm64:allmodconfig
	avr32:defconfig
	avr32:merisc_defconfig
	avr32:atngw100mkii_evklcd101_defconfig
	blackfin:defconfig
	blackfin:BF561-EZKIT-SMP_defconfig
	c6x:dsk6455_defconfig
	c6x:evmc6457_defconfig
	c6x:evmc6678_defconfig
	frv:defconfig
	ia64:defconfig
	ia64:allnoconfig
	m68k:allmodconfig
	microblaze:nommu_defconfig
	microblaze:allnoconfig
	mn10300:asb2303_defconfig
	mn10300:asb2364_defconfig
	parisc:allmodconfig
	powerpc:ppc6xx_defconfig
	s390:defconfig
	s390:allmodconfig
	s390:allnoconfig
	xtensa:allmodconfig
Qemu test results:
	total: 96 pass: 83 fail: 13
Failed tests:
	arm:kzm:imx_v6_v7_defconfig
	arm64:smp:defconfig
	arm64:nosmp:defconfig
	microblaze:microblaze_defconfig
	microblaze:microblazeel_defconfig
	powerpc:mac99:ppc_book3s_defconfig
	powerpc:mpc8544ds:mpc85xx_smp_defconfig
	powerpc:smp4:ppc64_book3s_defconfig
	powerpc:nosmp:ppc64_e5500_defconfig
	powerpc:smp:ppc64_e5500_defconfig
	s390:defconfig
	sparc64:sun4u:nosmp:sparc64_defconfig
	sparc64:sun4v:nosmp:sparc64_defconfig

Not all, but most of the failures are due to 07dff8ae2bc5.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
