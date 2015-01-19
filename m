Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4712F6B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 01:18:17 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so36757335pab.0
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 22:18:17 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id h4si14730008pdp.62.2015.01.18.22.18.14
        for <linux-mm@kvack.org>;
        Sun, 18 Jan 2015 22:18:15 -0800 (PST)
Date: Mon, 19 Jan 2015 15:19:02 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: mmotm 2015-01-16-15-50 uploaded
Message-ID: <20150119061902.GC11473@js1304-P5Q-DELUXE>
References: <54b9a3ce.lQ94nh84G4XJawsQ%akpm@linux-foundation.org>
 <20150117064023.GA5743@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150117064023.GA5743@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, Jan 16, 2015 at 10:40:23PM -0800, Guenter Roeck wrote:
> On Fri, Jan 16, 2015 at 03:50:38PM -0800, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2015-01-16-15-50 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> > 
> 
> This version is a bit worse than usual.
> 
> Build results:
> 	total: 133 pass: 113 fail: 20
> Failed builds:
> 	alpha:defconfig
> 	alpha:allmodconfig
> 	m32r:defconfig
> 	m68k:defconfig
> 	m68k:allmodconfig
> 	m68k:sun3_defconfig
> 	m68k:m5475evb_defconfig
> 	microblaze:mmu_defconfig
> 	mips:allmodconfig
> 	parisc:defconfig
> 	parisc:generic-32bit_defconfig
> 	parisc:a500_defconfig
> 	parisc:generic-64bit_defconfig
> 	powerpc:cell_defconfig
> 	powerpc:mpc85xx_defconfig
> 	powerpc:mpc85xx_smp_defconfig
> 	powerpc:cell_defconfig
> 	powerpc:mpc85xx_defconfig
> 	powerpc:mpc85xx_smp_defconfig
> 	sparc32:defconfig
> Qemu tests:
> 	total: 30 pass: 18 fail: 12
> Failed tests:
> 	alpha:alpha_defconfig
> 	microblaze:microblaze_defconfig
> 	microblaze:microblazeel_defconfig
> 	mips:mips_malta_smp_defconfig
> 	mips64:mips_malta64_smp_defconfig
> 	powerpc:ppc_book3s_smp_defconfig
> 	powerpc:ppc64_book3s_smp_defconfig
> 	sh:sh_defconfig
> 	sparc32:sparc_defconfig
> 	sparc32:sparc_smp_defconfig
> 	x86:x86_pc_defconfig
> 	x86_64:x86_64_pc_defconfig
> 
> Details are available at http://server.roeck-us.net:8010/builders; look for the
> 'mmotm' logs.
> 
> Patches identified as bad by bisect (see below for bisect logs):
> 
> 3ecd42e200dc mm/hugetlb: reduce arch dependent code around follow_huge_*
> c824a9dc5e88 mm: account pmd page tables to the process
> 825e778f321e mm/slub: optimize alloc/free fastpath by removing preemption on/off

Hello,

I sent the fix for testing failure due to 825e778f321e.

https://lkml.org/lkml/2015/1/19/17

It would fix this testing failure.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
