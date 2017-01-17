Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF3A16B0069
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:58:36 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y143so278348093pfb.6
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 22:58:36 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id u22si23994467plj.70.2017.01.16.22.58.35
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 22:58:36 -0800 (PST)
Date: Tue, 17 Jan 2017 15:58:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/3] Reverted "mm: bail out in shrink_inactive_list()"
Message-ID: <20170117065833.GD9812@blaptop>
References: <20170116160123.GB30300@cmpxchg.org>
 <20170116193317.20390-1-mhocko@kernel.org>
 <20170116193317.20390-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170116193317.20390-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Jan 16, 2017 at 08:33:17PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> This reverts 91dcade47a3d0e7c31464ef05f56c08e92a0e9c2.
> inactive_reclaimable_pages shouldn't be needed anymore since that
> get_scan_count is aware of the eligble zones ("mm, vmscan: consider
> eligible zones in get_scan_count").
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
