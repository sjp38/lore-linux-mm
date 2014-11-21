Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id B69576B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 17:32:21 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id w10so6091968pde.5
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 14:32:21 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id tz10si10931712pac.112.2014.11.21.14.32.19
        for <linux-mm@kvack.org>;
        Fri, 21 Nov 2014 14:32:20 -0800 (PST)
Date: Fri, 21 Nov 2014 14:32:18 -0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [balancenuma:mm-numa-protnone-v3r3 83/362]
 include/linux/compaction.h:108:1: error: expected identifier or '(' before
 '{' token
Message-ID: <20141121223218.GA22303@wfg-t540p.sh.intel.com>
References: <201411220114.QnSQfMwJ%fengguang.wu@intel.com>
 <20141121132105.f48085180ac3756028d0a846@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141121132105.f48085180ac3756028d0a846@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, kbuild-all@01.org, Mel Gorman <mgorman@suse.de>, Linux Memory Management List <linux-mm@kvack.org>

Hi Andrew,

On Fri, Nov 21, 2014 at 01:21:05PM -0800, Andrew Morton wrote:
> On Sat, 22 Nov 2014 01:20:17 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma mm-numa-protnone-v3r3
> > head:   e5d6f2e502e06020eeb0f852a5ed853802799eb3
> > commit: 17d9af0e32bdc4f263e23daefea699ed463bb87c [83/362] mm, compaction: simplify deferred compaction
> > config: x86_64-allnoconfig (attached as .config)
> > reproduce:
> >   git checkout 17d9af0e32bdc4f263e23daefea699ed463bb87c
> >   # save the attached .config to linux build tree
> >   make ARCH=x86_64 
> > 
> > Note: the balancenuma/mm-numa-protnone-v3r3 HEAD e5d6f2e502e06020eeb0f852a5ed853802799eb3 builds fine.
> >       It only hurts bisectibility.
> > 
> > All error/warnings:
> > 
> >    In file included from kernel/sysctl.c:43:0:
> > >> include/linux/compaction.h:108:1: error: expected identifier or '(' before '{' token
> >     {
> 
> That's fixed in the next patch,
> mm-compaction-simplify-deferred-compaction-fix.patch.
> 
> Your bisectbot broke again :)

Sorry about that! I checked it quickly and find the root cause is,
the check for your XXX-fix patches was limited to 3 trees:
(next|mmotm|memcg) and now we see it in the balancenuma tree.

The fix would be simple: just remove the extra tree test. :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
