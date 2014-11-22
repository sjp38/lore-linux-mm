Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id C81DC6B0069
	for <linux-mm@kvack.org>; Sat, 22 Nov 2014 02:45:51 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id x12so8399031wgg.33
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 23:45:51 -0800 (PST)
Received: from mx2.suse.de ([195.135.220.15])
        by mx.google.com with ESMTPS id eq8si2684520wib.54.2014.11.21.23.45.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 23:45:50 -0800 (PST)
Date: Sat, 22 Nov 2014 07:45:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [balancenuma:mm-numa-protnone-v3r3 83/362]
 include/linux/compaction.h:108:1: error: expected identifier or '(' before
 '{' token
Message-ID: <20141122074544.GB2725@suse.de>
References: <201411220114.QnSQfMwJ%fengguang.wu@intel.com>
 <20141121132105.f48085180ac3756028d0a846@linux-foundation.org>
 <20141121223218.GA22303@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20141121223218.GA22303@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Nov 21, 2014 at 02:32:18PM -0800, Fengguang Wu wrote:
> Hi Andrew,
> 
> On Fri, Nov 21, 2014 at 01:21:05PM -0800, Andrew Morton wrote:
> > On Sat, 22 Nov 2014 01:20:17 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> > 
> > > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma mm-numa-protnone-v3r3
> > > head:   e5d6f2e502e06020eeb0f852a5ed853802799eb3
> > > commit: 17d9af0e32bdc4f263e23daefea699ed463bb87c [83/362] mm, compaction: simplify deferred compaction
> > > config: x86_64-allnoconfig (attached as .config)
> > > reproduce:
> > >   git checkout 17d9af0e32bdc4f263e23daefea699ed463bb87c
> > >   # save the attached .config to linux build tree
> > >   make ARCH=x86_64 
> > > 
> > > Note: the balancenuma/mm-numa-protnone-v3r3 HEAD e5d6f2e502e06020eeb0f852a5ed853802799eb3 builds fine.
> > >       It only hurts bisectibility.
> > > 
> > > All error/warnings:
> > > 
> > >    In file included from kernel/sysctl.c:43:0:
> > > >> include/linux/compaction.h:108:1: error: expected identifier or '(' before '{' token
> > >     {
> > 
> > That's fixed in the next patch,
> > mm-compaction-simplify-deferred-compaction-fix.patch.
> > 
> > Your bisectbot broke again :)
> 
> Sorry about that! I checked it quickly and find the root cause is,
> the check for your XXX-fix patches was limited to 3 trees:
> (next|mmotm|memcg) and now we see it in the balancenuma tree.
> 

Sorry, that was entirely my fault. It's because mm-numa-protnone-v3r3
has been rebased on top of mmotm in preparation for sending to Andrew.
It's a one-off. Can just that branch be disabled?

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
