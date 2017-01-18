Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 728C26B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 11:48:39 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c206so4132251wme.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:48:39 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 3si952766wrr.176.2017.01.18.08.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 08:48:38 -0800 (PST)
Date: Wed, 18 Jan 2017 11:48:31 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] Revert "mm: bail out in shrink_inactive_list()"
Message-ID: <20170118164831.GC32495@cmpxchg.org>
References: <20170117103702.28542-1-mhocko@kernel.org>
 <20170117103702.28542-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117103702.28542-4-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Jan 17, 2017 at 11:37:02AM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> This reverts commit 91dcade47a3d0e7c31464ef05f56c08e92a0e9c2.
> 
> inactive_reclaimable_pages shouldn't be needed anymore since
> that get_scan_count is aware of the eligble zones ("mm, vmscan:
> consider eligible zones in get_scan_count").
> 
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpchxg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
