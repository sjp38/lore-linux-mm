Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id AD9396B0255
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 15:46:45 -0500 (EST)
Received: by wmec201 with SMTP id c201so3656446wme.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 12:46:45 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 72si8114187wmt.121.2015.11.25.12.46.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 12:46:44 -0800 (PST)
Date: Wed, 25 Nov 2015 15:46:35 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] drm/i915: Disable shrinker for non-swapped backed
 objects
Message-ID: <20151125204635.GA14536@cmpxchg.org>
References: <20151124231738.GA15770@nuc-i3427.alporthouse.com>
 <1448476616-5257-1-git-send-email-chris@chris-wilson.co.uk>
 <20151125190610.GA12238@cmpxchg.org>
 <20151125203102.GJ22980@nuc-i3427.alporthouse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151125203102.GJ22980@nuc-i3427.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Akash Goel <akash.goel@intel.com>, sourab.gupta@intel.com

On Wed, Nov 25, 2015 at 08:31:02PM +0000, Chris Wilson wrote:
> On Wed, Nov 25, 2015 at 02:06:10PM -0500, Johannes Weiner wrote:
> > On Wed, Nov 25, 2015 at 06:36:56PM +0000, Chris Wilson wrote:
> > > +static bool swap_available(void)
> > > +{
> > > +	return total_swap_pages || frontswap_enabled;
> > > +}
> > 
> > If you use get_nr_swap_pages() instead of total_swap_pages, this will
> > also stop scanning objects once the swap space is full. We do that in
> > the VM to stop scanning anonymous pages.
> 
> Thanks. Would EXPORT_SYMBOL_GPL(nr_swap_pages) (or equivalent) be
> acceptable?

No opposition from me. Just please add a small comment that this is
for shrinkers with swappable objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
