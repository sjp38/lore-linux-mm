Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 41A296B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 12:34:35 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id r129so35320136wmr.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:34:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ha10si16590658wjc.117.2016.01.28.09.34.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 09:34:34 -0800 (PST)
Subject: Re: [linux-next:master 1860/2084] include/linux/mm.h:1602:2: note: in
 expansion of macro 'spin_lock_init'
References: <201601281504.800eqd3p%fengguang.wu@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56AA5126.2030101@suse.cz>
Date: Thu, 28 Jan 2016 18:34:30 +0100
MIME-Version: 1.0
In-Reply-To: <201601281504.800eqd3p%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On 01/28/2016 08:23 AM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   888c8375131656144c1605071eab2eb6ac49abc3
> commit: cec08ed70d3d5209368a435fed278ae667117a0c [1860/2084] mm, printk: introduce new format string for flags
> config: s390-allyesconfig (attached as .config)
> reproduce:
>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          git checkout cec08ed70d3d5209368a435fed278ae667117a0c
>          # save the attached .config to linux build tree
>          make.cross ARCH=s390
> 
> All error/warnings (new ones prefixed by >>):
> 
>     In file included from include/linux/spinlock.h:81:0,
>                      from include/linux/rcupdate.h:38,
>                      from include/linux/tracepoint.h:19,
>                      from include/linux/mmdebug.h:7,
>                      from arch/s390/include/asm/cmpxchg.h:10,
>                      from arch/s390/include/asm/atomic.h:19,
>                      from include/linux/atomic.h:4,
>                      from include/linux/debug_locks.h:5,
>                      from include/linux/lockdep.h:23,
>                      from include/linux/hardirq.h:5,
>                      from include/linux/kvm_host.h:10,
>                      from arch/s390/kernel/asm-offsets.c:10:
>>> include/linux/spinlock_types.h:30:21: error: field 'dep_map' has incomplete type
>       struct lockdep_map dep_map;
>                          ^

Damn, a rebasing mistake in my series, sorry about that.
This should help. Can it be applied to -next? I think Andrew said he
would be travelling...

----8<----
