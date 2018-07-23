Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 908F96B026C
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 17:57:48 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 70-v6so1297462plc.1
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 14:57:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x7-v6sor3272863plr.20.2018.07.23.14.57.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 14:57:47 -0700 (PDT)
Date: Mon, 23 Jul 2018 14:57:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [mmotm:master 171/351] mm/vmacache.c:14:39: error: 'PMD_SHIFT'
 undeclared; did you mean 'PUD_SHIFT'?
In-Reply-To: <201807211152.qkpCcW5b%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.21.1807231456410.109445@chino.kir.corp.google.com>
References: <201807211152.qkpCcW5b%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, 21 Jul 2018, kbuild test robot wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   51e69b1d3de18116a5dceb6b144444dfdf136dc7
> commit: 77ecf9bc0e3d673d4d561cedc1d01c7a84ef90b7 [171/351] mm, vmacache: hash addresses based on pmd
> config: arm-allnoconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 77ecf9bc0e3d673d4d561cedc1d01c7a84ef90b7
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.2.0 make.cross ARCH=arm 
> 

I've got my cross compiler back up and working.  This is occurring because 
allnconfig is disabling CONFIG_MMU so we don't have PMD_SHIFT (there's 
only a pgdir).  I'll send patch to fix the build errors.
