Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 780146B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 05:41:15 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so134267693wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 02:41:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m3si577580wif.62.2015.09.14.02.41.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Sep 2015 02:41:13 -0700 (PDT)
Date: Mon, 14 Sep 2015 11:41:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [memcg:since-4.2 242/301]
 include/uapi/asm-generic/unistd.h:713:1: error: array index in initializer
 exceeds array bounds
Message-ID: <20150914094111.GC7050@dhcp22.suse.cz>
References: <201509122057.ogijChwU%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201509122057.ogijChwU%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Eric B Munson <emunson@akamai.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat 12-09-15 20:22:58, Wu Fengguang wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.2
> head:   62799b075621cec2d2a777837187a2885ccd977e
> commit: ad2ff3822c558e410ca3f4bd6ed9f0ea18c59e58 [242/301] mm: mlock: add new mlock system call
> config: openrisc-or1ksim_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout ad2ff3822c558e410ca3f4bd6ed9f0ea18c59e58
>   # save the attached .config to linux build tree
>   make.cross ARCH=openrisc 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    In file included from include/asm-generic/unistd.h:1:0,
>                     from arch/openrisc/include/uapi/asm/unistd.h:26,
>                     from arch/openrisc/kernel/sys_call_table.c:27:
> >> include/uapi/asm-generic/unistd.h:713:1: error: array index in initializer exceeds array bounds
>    include/uapi/asm-generic/unistd.h:713:1: error: (near initialization for 'sys_call_table')
> 
> vim +713 include/uapi/asm-generic/unistd.h
> 
>    707	__SYSCALL(__NR_memfd_create, sys_memfd_create)
>    708	#define __NR_bpf 280
>    709	__SYSCALL(__NR_bpf, sys_bpf)
>    710	#define __NR_execveat 281
>    711	__SC_COMP(__NR_execveat, sys_execveat, compat_sys_execveat)
>    712	#define __NR_mlock2 283
>  > 713	__SYSCALL(__NR_mlock2, sys_mlock2)
>    714	
>    715	#undef __NR_syscalls
>    716	#define __NR_syscalls 283

My fault! I have misapplied the patch. Thanks for catching this up.
Pushed to my tree.
---
