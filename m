Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id BA12E6B0038
	for <linux-mm@kvack.org>; Sat, 22 Nov 2014 13:18:25 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id w10so7256937pde.19
        for <linux-mm@kvack.org>; Sat, 22 Nov 2014 10:18:25 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id im9si13944434pbc.189.2014.11.22.10.18.23
        for <linux-mm@kvack.org>;
        Sat, 22 Nov 2014 10:18:24 -0800 (PST)
Date: Sat, 22 Nov 2014 10:18:16 -0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [balancenuma:mm-numa-protnone-v3r3 83/362]
 include/linux/compaction.h:108:1: error: expected identifier or '(' before
 '{' token
Message-ID: <20141122181816.GA28646@wfg-t540p.sh.intel.com>
References: <201411220114.QnSQfMwJ%fengguang.wu@intel.com>
 <20141121132105.f48085180ac3756028d0a846@linux-foundation.org>
 <20141121223218.GA22303@wfg-t540p.sh.intel.com>
 <20141122074544.GB2725@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141122074544.GB2725@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

Hi Mel,

On Sat, Nov 22, 2014 at 07:45:44AM +0000, Mel Gorman wrote:
> On Fri, Nov 21, 2014 at 02:32:18PM -0800, Fengguang Wu wrote:
> > Hi Andrew,
> > 
> > On Fri, Nov 21, 2014 at 01:21:05PM -0800, Andrew Morton wrote:
> > > On Sat, 22 Nov 2014 01:20:17 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> > > 
> > > > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma mm-numa-protnone-v3r3
> > > > head:   e5d6f2e502e06020eeb0f852a5ed853802799eb3
> > > > commit: 17d9af0e32bdc4f263e23daefea699ed463bb87c [83/362] mm, compaction: simplify deferred compaction
> > > > config: x86_64-allnoconfig (attached as .config)
> > > > reproduce:
> > > >   git checkout 17d9af0e32bdc4f263e23daefea699ed463bb87c
> > > >   # save the attached .config to linux build tree
> > > >   make ARCH=x86_64 
> > > > 
> > > > Note: the balancenuma/mm-numa-protnone-v3r3 HEAD e5d6f2e502e06020eeb0f852a5ed853802799eb3 builds fine.
> > > >       It only hurts bisectibility.
> > > > 
> > > > All error/warnings:
> > > > 
> > > >    In file included from kernel/sysctl.c:43:0:
> > > > >> include/linux/compaction.h:108:1: error: expected identifier or '(' before '{' token
> > > >     {
> > > 
> > > That's fixed in the next patch,
> > > mm-compaction-simplify-deferred-compaction-fix.patch.
> > > 
> > > Your bisectbot broke again :)
> > 
> > Sorry about that! I checked it quickly and find the root cause is,
> > the check for your XXX-fix patches was limited to 3 trees:
> > (next|mmotm|memcg) and now we see it in the balancenuma tree.
> > 
> 
> Sorry, that was entirely my fault. It's because mm-numa-protnone-v3r3
> has been rebased on top of mmotm in preparation for sending to Andrew.
> It's a one-off. Can just that branch be disabled?

It's fine, I've made the 0day bot to deal with the general situation
that MM developers base their tree on Andrew's.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
