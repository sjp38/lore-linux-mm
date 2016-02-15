Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7CBF86B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 15:06:08 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id a4so70735525wme.1
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 12:06:08 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id k71si6024339wmd.15.2016.02.15.12.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 12:06:07 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id a4so12243384wme.3
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 12:06:06 -0800 (PST)
Date: Mon, 15 Feb 2016 21:06:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160215200603.GA9223@dhcp22.suse.cz>
References: <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.DEB.2.10.1602031457120.10331@chino.kir.corp.google.com>
 <20160204125700.GA14425@dhcp22.suse.cz>
 <201602042210.BCG18704.HOMFFJOStQFOLV@I-love.SAKURA.ne.jp>
 <20160204133905.GB14425@dhcp22.suse.cz>
 <201602071309.EJD59750.FOVMSFOOFHtJQL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602071309.EJD59750.FOVMSFOOFHtJQL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 07-02-16 13:09:33, Tetsuo Handa wrote:
[...]
> FYI, I again hit unexpected OOM-killer during genxref on linux-4.5-rc2 source.
> I think current patchset is too fragile to merge.
> ----------------------------------------
> [ 3101.626995] smbd invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
> [ 3101.629148] smbd cpuset=/ mems_allowed=0
[...]
> [ 3101.705887] Node 0 DMA: 75*4kB (UME) 69*8kB (UME) 43*16kB (UM) 23*32kB (UME) 8*64kB (UM) 4*128kB (UME) 2*256kB (UM) 0*512kB 1*1024kB (U) 1*2048kB (M) 0*4096kB = 6884kB
> [ 3101.710581] Node 0 DMA32: 4513*4kB (UME) 15*8kB (U) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 18172kB

How come this is an unexpected OOM? There is clearly no order-2+ page
available for the allocation request.

> > Something like the following:
> Yes, I do think we need something like it.

Was the patch applied?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
