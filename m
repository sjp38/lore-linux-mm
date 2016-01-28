Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id F1C4A6B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 17:23:57 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id d63so53512078ioj.2
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 14:23:57 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id r37si8861493ioe.122.2016.01.28.14.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 14:23:56 -0800 (PST)
Date: Fri, 29 Jan 2016 09:23:52 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [linux-next:master 1860/2084] include/linux/mm.h:1602:2: note:
 in expansion of macro 'spin_lock_init'
Message-ID: <20160129092352.7b60a7e0@canb.auug.org.au>
In-Reply-To: <56AA5126.2030101@suse.cz>
References: <201601281504.800eqd3p%fengguang.wu@intel.com>
	<56AA5126.2030101@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Vlastimil,

On Thu, 28 Jan 2016 18:34:30 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 01/28/2016 08:23 AM, kbuild test robot wrote:
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   888c8375131656144c1605071eab2eb6ac49abc3
> > commit: cec08ed70d3d5209368a435fed278ae667117a0c [1860/2084] mm, printk: introduce new format string for flags
> > config: s390-allyesconfig (attached as .config)
> > reproduce:
> >          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
> >          chmod +x ~/bin/make.cross
> >          git checkout cec08ed70d3d5209368a435fed278ae667117a0c
> >          # save the attached .config to linux build tree
> >          make.cross ARCH=s390
> > 
> > All error/warnings (new ones prefixed by >>):
> > 
> >     In file included from include/linux/spinlock.h:81:0,
> >                      from include/linux/rcupdate.h:38,
> >                      from include/linux/tracepoint.h:19,
> >                      from include/linux/mmdebug.h:7,
> >                      from arch/s390/include/asm/cmpxchg.h:10,
> >                      from arch/s390/include/asm/atomic.h:19,
> >                      from include/linux/atomic.h:4,
> >                      from include/linux/debug_locks.h:5,
> >                      from include/linux/lockdep.h:23,
> >                      from include/linux/hardirq.h:5,
> >                      from include/linux/kvm_host.h:10,
> >                      from arch/s390/kernel/asm-offsets.c:10:  
> >>> include/linux/spinlock_types.h:30:21: error: field 'dep_map' has incomplete type  
> >       struct lockdep_map dep_map;
> >                          ^  
> 
> Damn, a rebasing mistake in my series, sorry about that.
> This should help. Can it be applied to -next? I think Andrew said he
> would be travelling...

Added to linux-next by hand today.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
