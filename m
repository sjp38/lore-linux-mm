Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 95CA66B0512
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 10:20:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p14so267008wrg.8
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 07:20:43 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id p7si1360840wrd.354.2017.08.23.07.20.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 07:20:42 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20170822154550.33c8cc61c21e5ccf72959dd1@linux-foundation.org>
References: <20170815153010.e3cfc177af0b2c0dc421b84c@linux-foundation.org>
 <20170822135325.9191-1-chris@chris-wilson.co.uk>
 <20170822135325.9191-2-chris@chris-wilson.co.uk>
 <20170822154550.33c8cc61c21e5ccf72959dd1@linux-foundation.org>
Message-ID: <150349800761.25258.2258911582898268561@mail.alporthouse.com>
Subject: Re: [PATCH 2/2] drm/i915: Wire up shrinkctl->nr_scanned
Date: Wed, 23 Aug 2017 15:20:07 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Shaohua Li <shli@fb.com>

Quoting Andrew Morton (2017-08-22 23:45:50)
> On Tue, 22 Aug 2017 14:53:25 +0100 Chris Wilson <chris@chris-wilson.co.uk=
> wrote:
> =

> > shrink_slab() allows us to report back the number of objects we
> > successfully scanned (out of the target shrinkctl->nr_to_scan). As
> > report the number of pages owned by each GEM object as a separate item
> > to the shrinker, we cannot precisely control the number of shrinker
> > objects we scan on each pass; and indeed may free more than requested.
> > If we fail to tell the shrinker about the number of objects we process,
> > it will continue to hold a grudge against us as any objects left
> > unscanned are added to the next reclaim -- and so we will keep on
> > "unfairly" shrinking our own slab in comparison to other slabs.
> =

> It's unclear which tree this is against but I think I got it all fixed
> up.  Please check the changes to i915_gem_shrink().

My apologies, I wrote it against drm-tip for running against our CI. The
changes look fine, thank you.
-Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
