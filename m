Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id 04FAF6B0036
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 23:18:31 -0500 (EST)
Received: by mail-yh0-f50.google.com with SMTP id b6so3540817yha.37
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 20:18:31 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id s6si12369480yho.114.2013.12.09.20.18.29
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 20:18:31 -0800 (PST)
Date: Tue, 10 Dec 2013 15:18:26 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v13 13/16] vmscan: take at least one pass with shrinkers
Message-ID: <20131210041826.GB31386@dastard>
References: <cover.1386571280.git.vdavydov@parallels.com>
 <5287164773f8aade33ce17f3c91546c6e1afaf85.1386571280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5287164773f8aade33ce17f3c91546c6e1afaf85.1386571280.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, Glauber Costa <gloomer@openvz.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Mon, Dec 09, 2013 at 12:05:54PM +0400, Vladimir Davydov wrote:
> From: Glauber Costa <glommer@openvz.org>
> 
> In very low free kernel memory situations, it may be the case that we
> have less objects to free than our initial batch size. If this is the
> case, it is better to shrink those, and open space for the new workload
> then to keep them and fail the new allocations.
> 
> In particular, we are concerned with the direct reclaim case for memcg.
> Although this same technique can be applied to other situations just as
> well, we will start conservative and apply it for that case, which is
> the one that matters the most.

This should be at the start of the series.

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
