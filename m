Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC176B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 04:22:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so97867138wmz.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 01:22:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ds7si1469280wjd.223.2016.08.02.01.22.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 01:22:48 -0700 (PDT)
Date: Tue, 2 Aug 2016 09:22:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [   25.666092] WARNING: CPU: 0 PID: 451 at mm/memcontrol.c:998
 mem_cgroup_update_lru_size
Message-ID: <20160802082243.GE2693@suse.de>
References: <20160801013830.GB27998@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160801013830.GB27998@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKP <lkp@01.org>

On Mon, Aug 01, 2016 at 09:38:30AM +0800, Fengguang Wu wrote:
> Greetings,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git mm-vmscan-node-lru-follow-up-v2r1
> 
> commit d5d54a2c5517f0818ad75a2f5b1d26a0dacae46a
> Author:     Mel Gorman <mgorman@techsingularity.net>
> AuthorDate: Wed Jul 13 09:30:01 2016 +0100
> Commit:     Mel Gorman <mgorman@techsingularity.net>
> CommitDate: Wed Jul 13 09:30:01 2016 +0100
> 

That bug is addressed later in the tree by "mm, vmscan: Update all zone
LRU sizes before updating memcg". Is the warning visible in the latest
mainline tree?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
