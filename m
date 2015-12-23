Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7877182F97
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 17:04:47 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l126so161441395wml.1
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 14:04:47 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e17si67337478wjr.188.2015.12.23.14.04.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Dec 2015 14:04:46 -0800 (PST)
Date: Wed, 23 Dec 2015 17:04:27 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Intel-gfx] [PATCH v2 1/2] mm: Export nr_swap_pages
Message-ID: <20151223220427.GA11412@cmpxchg.org>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
 <20151204160952.GA24927@cmpxchg.org>
 <20151210093242.GH20822@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151210093242.GH20822@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, "Goel, Akash" <akash.goel@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Dec 10, 2015 at 10:32:42AM +0100, Daniel Vetter wrote:
> On Fri, Dec 04, 2015 at 11:09:52AM -0500, Johannes Weiner wrote:
> > On Fri, Dec 04, 2015 at 03:58:53PM +0000, Chris Wilson wrote:
> > > Some modules, like i915.ko, use swappable objects and may try to swap
> > > them out under memory pressure (via the shrinker). Before doing so, they
> > > want to check using get_nr_swap_pages() to see if any swap space is
> > > available as otherwise they will waste time purging the object from the
> > > device without recovering any memory for the system. This requires the
> > > nr_swap_pages counter to be exported to the modules.
> > > 
> > > Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> > > Cc: "Goel, Akash" <akash.goel@intel.com>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: linux-mm@kvack.org
> > 
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Ack for merging this through drm-intel trees for 4.5? I'm a bit unclear
> who's ack I need for that for linux-mm topics ...

Andrew would be the -mm maintainer. CC'd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
