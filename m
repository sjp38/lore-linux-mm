Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id D35B46B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 16:00:12 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id va2so26126954obc.7
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 13:00:12 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id e139si5820716oic.20.2015.01.30.13.00.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 13:00:12 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YHIfk-003d98-3d
	for linux-mm@kvack.org; Fri, 30 Jan 2015 21:00:12 +0000
Date: Fri, 30 Jan 2015 12:59:58 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 00/19] expose page table levels on Kconfig leve
Message-ID: <20150130205958.GA1124@roeck-us.net>
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150130172613.GA12367@roeck-us.net>
 <20150130185052.GA30401@node.dhcp.inet.fi>
 <20150130191435.GA16823@roeck-us.net>
 <20150130200956.GB30401@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150130200956.GB30401@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 30, 2015 at 10:09:56PM +0200, Kirill A. Shutemov wrote:
> On Fri, Jan 30, 2015 at 11:14:35AM -0800, Guenter Roeck wrote:
> > On Fri, Jan 30, 2015 at 08:50:52PM +0200, Kirill A. Shutemov wrote:
> > > On Fri, Jan 30, 2015 at 09:26:13AM -0800, Guenter Roeck wrote:
> > > > On Fri, Jan 30, 2015 at 04:43:09PM +0200, Kirill A. Shutemov wrote:
> > > > > I've failed my attempt on split up mm_struct into separate header file to
> > > > > be able to use defines from <asm/pgtable.h> to define mm_struct: it causes
> > > > > too much breakage and requires massive de-inlining of some architectures
> > > > > (notably ARM and S390 with PGSTE).
> > > > > 
> > > > > This is other approach: expose number of page table levels on Kconfig
> > > > > level and use it to get rid of nr_pmds in mm_struct.
> > > > > 
> > > > Hi Kirill,
> > > > 
> > > > Can I pull this series from somewhere ?
> > > 
> > > Just pushed:
> > > 
> > > git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git config_pgtable_levels
> > > 
> > 
> > Great. Pushed into my 'testing' branch. I'll let you know how it goes.
> 
> 0-DAY kernel testing has already reported few issues on blackfin, ia64 and
> x86 with xen.
> 
Here is the final verdict:
	total: 134 pass: 114 fail: 20
Failed builds:
	arc:defconfig (inherited from mainline)
	arc:tb10x_defconfig (inherited from mainline)
	arm:efm32_defconfig
	blackfin:defconfig
	c6x:dsk6455_defconfig
	c6x:evmc6457_defconfig
	c6x:evmc6678_defconfig
	ia64:defconfig
	m68k:m5272c3_defconfig
	m68k:m5307c3_defconfig
	m68k:m5249evb_defconfig
	m68k:m5407c3_defconfig
	microblaze:nommu_defconfig
	mips:allmodconfig (inherited from -next)
	powerpc:cell_defconfig (binutils 2.23)
	powerpc:cell_defconfig (binutils 2.24)
	sparc64:allmodconfig (inherited from -next)
	x86_64:allyesconfig
	x86_64:allmodconfig
	xtensa:allmodconfig (inherited from -next)

There are also qemu warnings for arm, but those are inherited from -next.

Good start overall ...

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
