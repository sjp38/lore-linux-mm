Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id ED2696B025A
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 11:10:05 -0500 (EST)
Received: by wmvv187 with SMTP id v187so81481847wmv.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 08:10:05 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ge7si19390358wjc.227.2015.12.04.08.10.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 08:10:04 -0800 (PST)
Date: Fri, 4 Dec 2015 11:09:52 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 1/2] mm: Export nr_swap_pages
Message-ID: <20151204160952.GA24927@cmpxchg.org>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, "Goel, Akash" <akash.goel@intel.com>, linux-mm@kvack.org

On Fri, Dec 04, 2015 at 03:58:53PM +0000, Chris Wilson wrote:
> Some modules, like i915.ko, use swappable objects and may try to swap
> them out under memory pressure (via the shrinker). Before doing so, they
> want to check using get_nr_swap_pages() to see if any swap space is
> available as otherwise they will waste time purging the object from the
> device without recovering any memory for the system. This requires the
> nr_swap_pages counter to be exported to the modules.
> 
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: "Goel, Akash" <akash.goel@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: linux-mm@kvack.org

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
