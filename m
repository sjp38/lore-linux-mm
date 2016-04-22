Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB81E6B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 17:50:00 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id vv3so171929362pab.2
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 14:50:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j25si8891389pfj.97.2016.04.22.14.49.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 14:50:00 -0700 (PDT)
Date: Fri, 22 Apr 2016 14:49:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/vmalloc: Keep a separate lazy-free list
Message-Id: <20160422144957.64619ee9b19991e4fdf89668@linux-foundation.org>
In-Reply-To: <20160415111431.GL19990@nuc-i3427.alporthouse.com>
References: <1460444239-22475-1-git-send-email-chris@chris-wilson.co.uk>
	<CACZ9PQV+H+i11E-GEfFeMD3cXWXOF1yPGJH8j7BLXQVqFB3oGw@mail.gmail.com>
	<20160414134926.GD19990@nuc-i3427.alporthouse.com>
	<CACZ9PQXCHRC5bFqQKmtOv+GyuEmEaXDVPJdQhBt0sXPfomFTNw@mail.gmail.com>
	<20160415111431.GL19990@nuc-i3427.alporthouse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Roman Peniaev <r.peniaev@gmail.com>, intel-gfx@lists.freedesktop.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Tvrtko Ursulin <tvrtko.ursulin@linux.intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Toshi Kani <toshi.kani@hp.com>, Shawn Lin <shawn.lin@rock-chips.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, 15 Apr 2016 12:14:31 +0100 Chris Wilson <chris@chris-wilson.co.uk> wrote:

> > > purge_fragmented_blocks() manages per-cpu lists, so that looks safe
> > > under its own rcu_read_lock.
> > >
> > > Yes, it looks feasible to remove the purge_lock if we can relax sync.
> > 
> > what is still left is waiting on vmap_area_lock for !sync mode.
> > but probably is not that bad.
> 
> Ok, that's bit beyond my comfort zone with a patch to change the free
> list handling. I'll chicken out for the time being, atm I am more
> concerned that i915.ko may call set_page_wb() frequently on individual
> pages.

Nick Piggin's vmap rewrite.  20x (or more) faster. 
https://lwn.net/Articles/285341/

10 years ago, never finished.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
