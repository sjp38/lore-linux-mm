Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 115D56B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 05:23:13 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so1527236pde.13
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 02:23:13 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fl7si560252pad.258.2014.02.06.02.23.12
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 02:23:13 -0800 (PST)
Date: Thu, 6 Feb 2014 18:23:11 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: WARNING: at arch/x86/kernel/smpboot.c:324 topology_sane()
Message-ID: <20140206102311.GA24615@localhost>
References: <20140206094428.GC17971@localhost>
 <52F35E71.3030105@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52F35E71.3030105@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Tang Chen <imtangchen@gmail.com>

On Thu, Feb 06, 2014 at 06:05:37PM +0800, Tang Chen wrote:
> On 02/06/2014 05:44 PM, Fengguang Wu wrote:
> >Hi Tang,
> >
> >We noticed the below warning and the first bad commit is
> >
> >commit e8d1955258091e4c92d5a975ebd7fd8a98f5d30f
> >Author:     Tang Chen<tangchen@cn.fujitsu.com>
> >AuthorDate: Fri Feb 22 16:33:44 2013 -0800
> >Commit:     Linus Torvalds<torvalds@linux-foundation.org>
> >CommitDate: Sat Feb 23 17:50:14 2013 -0800
> >
> >     acpi, memory-hotplug: parse SRAT before memblock is ready
> 
> Hi Wu,
> 
> This patch has been droped a long time ago. It is not in the latest kernel.
> 
> Now the memory hotplug implementation is done in a different way.

Great, and sorry for the noise! Yeah it's bisected between two old
kernels, I should have checked latest mainline kernel before reporting it.

Thanks,
Fengguang

> >  arch/x86/kernel/setup.c | 13 +++++++++----
> >  arch/x86/mm/numa.c      |  6 ++++--
> >  drivers/acpi/numa.c     | 23 +++++++++++++----------
> >  include/linux/acpi.h    |  8 ++++++++
> >  4 files changed, 34 insertions(+), 16 deletions(-)
> >
> >[    0.845092] smpboot: Booting Node   1, Processors  #1
> >[    0.864812] masked ExtINT on CPU#1
> >[    0.868706] CPU1: Thermal LVT vector (0xfa) already installed
> >[    0.875158] ------------[ cut here ]------------
> >[    0.880330] WARNING: at arch/x86/kernel/smpboot.c:324 topology_sane.isra.2+0x6b/0x7c()
> >[    0.891505] Hardware name: S2600CP
> >[    0.895314] sched: CPU #1's llc-sibling CPU #0 is not on the same node! [node: 1 != 0]. Ignoring dependency.
> >
> >[    0.906295] Modules linked in:
> >[    0.909927] Pid: 0, comm: swapper/1 Not tainted 3.8.0-06530-ge8d1955 #1
> >[    0.917314] Call Trace:
> >[    0.920055]  [<ffffffff81970409>] ? topology_sane.isra.2+0x6b/0x7c
> >[    0.926963]  [<ffffffff810bcd5d>] warn_slowpath_common+0x81/0x99
> >[    0.933667]  [<ffffffff810bcdc1>] warn_slowpath_fmt+0x4c/0x4e
> >[    0.940092]  [<ffffffff8196b565>] ? calibrate_delay+0xae/0x4ba
> >[    0.946612]  [<ffffffff810508ea>] ? __mcheck_cpu_init_timer+0x4a/0x4f
> >[    0.953799]  [<ffffffff81970409>] topology_sane.isra.2+0x6b/0x7c
> >[    0.960509]  [<ffffffff819706e0>] set_cpu_sibling_map+0x28c/0x43a
> >[    0.967308]  [<ffffffff81970a3c>] start_secondary+0x1ae/0x276
> >[    0.973742] ---[ end trace db722b2086ba6d20 ]---
> >[    0.999234]  OK
> >[    1.001655] smpboot: Booting Node   0, Processors  #2
> >
> >Full dmesg and kconfig are attached.
> >
> >Thanks,
> >Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
