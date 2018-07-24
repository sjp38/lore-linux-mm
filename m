Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 820FF6B000C
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 16:43:13 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n19-v6so3242458pgv.14
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:43:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z7-v6sor3862503plo.15.2018.07.24.13.43.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 13:43:12 -0700 (PDT)
Date: Tue, 24 Jul 2018 13:43:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [linux-next:master 7986/8610] mm/vmacache.c:14:39: error:
 'PMD_SHIFT' undeclared; did you mean 'NMI_SHIFT'?
In-Reply-To: <201807242217.aUOXI16w%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.21.1807241342050.185034@chino.kir.corp.google.com>
References: <201807242217.aUOXI16w%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, 24 Jul 2018, kbuild test robot wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   3946cd385042069ec57d3f04240def53b4eed7e5
> commit: 5d2f33872046e7ffdd62dd80472cd466ea8407ac [7986/8610] mm, vmacache: hash addresses based on pmd
> config: microblaze-nommu_defconfig (attached as .config)
> compiler: microblaze-linux-gcc (GCC) 8.1.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 5d2f33872046e7ffdd62dd80472cd466ea8407ac
>         # save the attached .config to linux build tree
>         GCC_VERSION=8.1.0 make.cross ARCH=microblaze 
> 
> Note: the linux-next/master HEAD 3946cd385042069ec57d3f04240def53b4eed7e5 builds fine.
>       It may have been fixed somewhere.
> 

Yes, this Note is accurate, nommu_defconfig on microblaze works fine at 
HEAD due to commit 63a0a84adc08 ("mm, vmacache: hash addresses based on 
pmd fix").  I'm not sure this should have sent an email, tbh.
