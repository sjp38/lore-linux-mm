Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 73A366B02AF
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 03:03:45 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id s28so26803002pfg.6
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 00:03:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v68si24183949pgv.557.2017.11.28.00.03.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 00:03:44 -0800 (PST)
Date: Tue, 28 Nov 2017 09:03:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmscan: try to optimize branch procedures.
Message-ID: <20171128080339.i3ktwm565pz7om4v@dhcp22.suse.cz>
References: <1511833785-55392-1-git-send-email-jiang.biao2@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511833785-55392-1-git-send-email-jiang.biao2@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Biao <jiang.biao2@zte.com.cn>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn

On Tue 28-11-17 09:49:45, Jiang Biao wrote:
> 1. Use unlikely to try to improve branch prediction. The
> *total_scan < 0* branch is unlikely to reach, so use unlikely.
> 
> 2. Optimize *next_deferred >= scanned* condition.
> *next_deferred >= scanned* condition could be optimized into
> *next_deferred > scanned*, because when *next_deferred == scanned*,
> next_deferred shoud be 0, which is covered by the else branch.
> 
> 3. Merge two branch blocks into one. The *next_deferred > 0* branch
> could be merged into *next_deferred > scanned* to simplify the code.

How have you measured benefit of this patch?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
