Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8C36B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 20:53:40 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so12903896pdj.3
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 17:53:39 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id nw8si2995238pbb.84.2015.06.11.17.53.39
        for <linux-mm@kvack.org>;
        Thu, 11 Jun 2015 17:53:39 -0700 (PDT)
Date: Fri, 12 Jun 2015 08:52:45 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [next:master 10274/10671]
 /kbuild/src/slow3/arch/arm/mach-tegra/cpuidle-tegra114.c:88: undefined
 reference to `psci_smp_available'
Message-ID: <20150612005245.GB11843@wfg-t540p.sh.intel.com>
References: <201506120455.HwpOSg84%fengguang.wu@intel.com>
 <1434060757.3165.96.camel@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434060757.3165.96.camel@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Davidlohr,

Sorry it's a wrong bisect. I'll fix the bisect script.

Thanks,
Fengguang

On Thu, Jun 11, 2015 at 03:12:37PM -0700, Davidlohr Bueso wrote:
> On Fri, 2015-06-12 at 04:45 +0800, kbuild test robot wrote:
> > Hi Davidlohr,
> > 
> > First bad commit (maybe != root cause):
> > 
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   f0939c364ffe7dc377c4d7946360f99cb7fc867b
> > commit: 48803a970534ad0411991de1d293996db8ea9aa0 [10274/10671] ipc,sysv: return -EINVAL upon incorrect id/seqnum
> 
> The below makes no sense with this commit. `psci_smp_available' has 0 to
> do with ipc.
> 
> > 
> > All error/warnings (new ones prefixed by >>):
> > 
> >    arch/arm/mach-tegra/built-in.o: In function `tegra114_cpuidle_init':
> > >> /kbuild/src/slow3/arch/arm/mach-tegra/cpuidle-tegra114.c:88: undefined reference to `psci_smp_available'
> 
> Thanks,
> Davidlohr
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
