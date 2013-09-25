Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id BA0B26B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 18:26:54 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so263830pbb.33
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 15:26:54 -0700 (PDT)
Date: Thu, 26 Sep 2013 08:26:38 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] drm/i915: Fix up usage of SHRINK_STOP
Message-ID: <20130925222638.GI26872@dastard>
References: <1380110402-24749-1-git-send-email-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380110402-24749-1-git-send-email-daniel.vetter@ffwll.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, Knut Petersen <Knut_Petersen@t-online.de>, Glauber Costa <glommer@openvz.org>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Wed, Sep 25, 2013 at 02:00:02PM +0200, Daniel Vetter wrote:
> In
> 
> commit 81e49f811404f428a9d9a63295a0c267e802fa12
> Author: Glauber Costa <glommer@openvz.org>
> Date:   Wed Aug 28 10:18:13 2013 +1000
> 
>     i915: bail out earlier when shrinker cannot acquire mutex
> 
> SHRINK_STOP was added to tell the core shrinker code to bail out and
> go to the next shrinker since the i915 shrinker couldn't acquire
> required locks. But the SHRINK_STOP return code was added to the
> ->count_objects callback and not the ->scan_objects callback as it
> should have been, resulting in tons of dmesg noise like
> 
> shrink_slab: i915_gem_inactive_scan+0x0/0x9c negative objects to delete nr=-xxxxxxxxx
> 
> Fix discusssed with Dave Chinner.

Acked-by: Dave Chinner <dchinner@redhat.com>

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
