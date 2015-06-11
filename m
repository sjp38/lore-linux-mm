Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 520856B006C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 18:12:51 -0400 (EDT)
Received: by wiga1 with SMTP id a1so140835wig.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 15:12:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5si3656614wja.1.2015.06.11.15.12.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 15:12:49 -0700 (PDT)
Message-ID: <1434060757.3165.96.camel@stgolabs.net>
Subject: Re: [next:master 10274/10671]
 /kbuild/src/slow3/arch/arm/mach-tegra/cpuidle-tegra114.c:88: undefined
 reference to `psci_smp_available'
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Thu, 11 Jun 2015 15:12:37 -0700
In-Reply-To: <201506120455.HwpOSg84%fengguang.wu@intel.com>
References: <201506120455.HwpOSg84%fengguang.wu@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 2015-06-12 at 04:45 +0800, kbuild test robot wrote:
> Hi Davidlohr,
> 
> First bad commit (maybe != root cause):
> 
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   f0939c364ffe7dc377c4d7946360f99cb7fc867b
> commit: 48803a970534ad0411991de1d293996db8ea9aa0 [10274/10671] ipc,sysv: return -EINVAL upon incorrect id/seqnum

The below makes no sense with this commit. `psci_smp_available' has 0 to
do with ipc.

> 
> All error/warnings (new ones prefixed by >>):
> 
>    arch/arm/mach-tegra/built-in.o: In function `tegra114_cpuidle_init':
> >> /kbuild/src/slow3/arch/arm/mach-tegra/cpuidle-tegra114.c:88: undefined reference to `psci_smp_available'

Thanks,
Davidlohr



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
