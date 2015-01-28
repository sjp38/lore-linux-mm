Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 17AB96B0071
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 13:50:59 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id h136so19037398oig.11
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 10:50:58 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id g128si2608456oib.138.2015.01.28.10.50.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 10:50:58 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YGXha-002B2d-3n
	for linux-mm@kvack.org; Wed, 28 Jan 2015 18:50:58 +0000
Date: Wed, 28 Jan 2015 10:50:52 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 0/4] Introduce <linux/mm_struct.h>
Message-ID: <20150128185052.GA6118@roeck-us.net>
References: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 28, 2015 at 03:17:40PM +0200, Kirill A. Shutemov wrote:
> This patchset moves definition of mm_struct into separate header file.
> It allows to get rid of nr_pmds if PMD page table level is folded.
> We cannot do it with current mm_types.h because we need
> __PAGETABLE_PMD_FOLDED from <asm/pgtable.h> which creates circular
> dependencies.
> 
> I've done few build tests and looks like it works, but I expect breakage
> on some configuration. Please test.
> 
Doesn't look good.

Build results:
	total: 134 pass: 63 fail: 71
Failed builds:
	arm:s3c2410_defconfig
	arm:omap2plus_defconfig
	arm:imx_v6_v7_defconfig
	arm:ixp4xx_defconfig
	arm:u8500_defconfig
	arm:multi_v5_defconfig
	arm:multi_v7_defconfig
	arm:omap1_defconfig
	arm:footbridge_defconfig
	arm:davinci_all_defconfig
	arm:mini2440_defconfig
	arm:rpc_defconfig
	arm:axm55xx_defconfig
	arm:mxs_defconfig
	arm:keystone_defconfig
	arm:vexpress_defconfig
	arm:imx_v4_v5_defconfig
	arm:at91_dt_defconfig
	arm:s3c6400_defconfig
	arm:lpc32xx_defconfig
	arm:shmobile_defconfig
	arm:nhk8815_defconfig
	arm:bcm2835_defconfig
	arm:sama5_defconfig
	arm:orion5x_defconfig
	arm:exynos_defconfig
	arm:cm_x2xx_defconfig
	arm:s5pv210_defconfig
	arm:integrator_defconfig
	arm:msm_defconfig
	arm:pxa910_defconfig
	arm:clps711x_defconfig
	avr32:defconfig
	avr32:merisc_defconfig
	avr32:atngw100mkii_evklcd101_defconfig
	cris:defconfig
	cris:etrax-100lx_defconfig
	cris:allnoconfig
	cris:artpec_3_defconfig
	cris:etraxfs_defconfig
	frv:defconfig
	hexagon:defconfig
	ia64:defconfig
	m68k:defconfig
	m68k:allmodconfig
	m68k:sun3_defconfig
	m68k:m5475evb_defconfig
	microblaze:mmu_defconfig
	mips:allmodconfig
	powerpc:ppc6xx_defconfig
	powerpc:mpc83xx_defconfig
	powerpc:mpc85xx_defconfig
	powerpc:mpc85xx_smp_defconfig
	powerpc:tqm8xx_defconfig
	powerpc:85xx/sbc8548_defconfig
	powerpc:83xx/mpc834x_mds_defconfig
	powerpc:86xx/sbc8641d_defconfig
	powerpc:ppc6xx_defconfig
	powerpc:mpc83xx_defconfig
	powerpc:mpc85xx_defconfig
	powerpc:mpc85xx_smp_defconfig
	powerpc:tqm8xx_defconfig
	powerpc:85xx/sbc8548_defconfig
	powerpc:83xx/mpc834x_mds_defconfig
	powerpc:86xx/sbc8641d_defconfig
	s390:defconfig
	sparc32:defconfig
	sparc64:defconfig
	sparc64:allmodconfig
	unicore32:defconfig
	xtensa:allmodconfig

Qemu tests:
	total: 30 pass: 20 fail: 10
Failed tests:
	arm:arm_versatile_defconfig
	arm:arm_vexpress_defconfig
	microblaze:microblaze_defconfig
	microblaze:microblazeel_defconfig
	powerpc:ppc_book3s_defconfig
	powerpc:ppc_book3s_smp_defconfig
	sparc32:sparc_defconfig
	sparc32:sparc_smp_defconfig
	sparc64:sparc_smp_defconfig
	sparc64:sparc_nosmp_defconfig

A few of those are other problems, but the majority is due to your patches.

Details are available at http://server.roeck-us.net:8010/builders;
look for the 'testing' column.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
