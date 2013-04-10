Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 248776B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 01:25:36 -0400 (EDT)
Date: Wed, 10 Apr 2013 14:26:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/3] mm, slub: count freed pages via rcu as this task's
 reclaimed_slab
Message-ID: <20130410052619.GD5872@lge.com>
References: <1365470478-645-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1365470478-645-2-git-send-email-iamjoonsoo.kim@lge.com>
 <0000013def3255c0-87577820-0ad9-46ac-8498-0589db4e7180-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013def3255c0-87577820-0ad9-46ac-8498-0589db4e7180-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

Hello, Christoph.

On Tue, Apr 09, 2013 at 02:28:06PM +0000, Christoph Lameter wrote:
> On Tue, 9 Apr 2013, Joonsoo Kim wrote:
> 
> > Currently, freed pages via rcu is not counted for reclaimed_slab, because
> > it is freed in rcu context, not current task context. But, this free is
> > initiated by this task, so counting this into this task's reclaimed_slab
> > is meaningful to decide whether we continue reclaim, or not.
> > So change code to count these pages for this task's reclaimed_slab.
> 
> slab->reclaim_state guides the reclaim actions in vmscan.c. With this
> patch slab->reclaim_state could get quite a high value without new pages being
> available for allocation. slab->reclaim_state will only be updated
> when the RCU period ends.

Okay.

In addition, there is a little place who use SLAB_DESTROY_BY_RCU.
I will drop this patch[2/3] and [3/3] for next spin.

Thanks.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
