Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A58846B03C1
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 07:51:11 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id a189so81797904qkc.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 04:51:11 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id l48si2839062qtb.285.2017.03.08.04.51.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 04:51:09 -0800 (PST)
Date: Wed, 8 Mar 2017 13:51:02 +0100
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH stable-4.9 0/2] mm: follow up oom fixes for 32b
Message-ID: <20170308125102.GA27694@kroah.com>
References: <20170228151108.20853-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228151108.20853-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stable tree <stable@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Trevor Cordes <trevor@tecnopolis.ca>

On Tue, Feb 28, 2017 at 04:11:06PM +0100, Michal Hocko wrote:
> Hi,
> later in the 4.10 release cycle it turned out that b4536f0c829c ("mm,
> memcg: fix the active list aging for lowmem requests when memcg is
> enabled") was not sufficient to fully close the regression introduced by
> f8d1a31163fc ("mm: consider whether to decivate based on eligible zones
> inactive ratio") [1]. mmotm tree behaved properly and it turned out the
> Linus tree was missing 71ab6cfe88dc ("mm, vmscan: consider eligible
> zones in get_scan_count") merged in 4.11 merge window. The patch heavily
> depends on 4a9494a3d827 ("mm, vmscan: cleanup lru size claculations")
> which has been backported as well (patch 1).
> 
> Please add these two to 4.9+ trees (they should apply to 4.10 as they
> are).  4.8 tree will need them as well but I do not see this stable tree
> being maintained.

For 4.10-stable I needed both of your backports, many thanks for them.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
