Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id E44E06B025A
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 11:11:06 -0500 (EST)
Received: by wmvv187 with SMTP id v187so81527373wmv.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 08:11:06 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ir3si19480598wjb.25.2015.12.04.08.11.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 08:11:06 -0800 (PST)
Date: Fri, 4 Dec 2015 11:11:01 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 2/2] drm/i915: Disable shrinker for non-swapped backed
 objects
Message-ID: <20151204161101.GB24927@cmpxchg.org>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
 <1449244734-25733-2-git-send-email-chris@chris-wilson.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449244734-25733-2-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Akash Goel <akash.goel@intel.com>, sourab.gupta@intel.com

On Fri, Dec 04, 2015 at 03:58:54PM +0000, Chris Wilson wrote:
> If the system has no available swap pages, we cannot make forward
> progress in the shrinker by releasing active pages, only by releasing
> purgeable pages which are immediately reaped. Take total_swap_pages into
> account when counting up available objects to be shrunk and subsequently
> shrinking them. By doing so, we avoid unbinding objects that cannot be
> shrunk and so wasting CPU cycles flushing those objects from the GPU to
> the system and then immediately back again (as they will more than
> likely be reused shortly after).
> 
> Based on a patch by Akash Goel.
> 
> v2: frontswap registers extra swap pages available for the system, so it
> is already include in the count of available swap pages.
> 
> v3: Use get_nr_swap_pages() to query the currently available amount of
> swap space. This should also stop us from shrinking the GPU buffers if
> we ever run out of swap space. Though at that point, we would expect the
> oom-notifier to be running and failing miserably...
> 
> Reported-by: Akash Goel <akash.goel@intel.com>
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: linux-mm@kvack.org
> Cc: Akash Goel <akash.goel@intel.com>
> Cc: sourab.gupta@intel.com

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
