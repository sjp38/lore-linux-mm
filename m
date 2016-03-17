Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 824296B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 09:30:33 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id l68so26340278wml.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 06:30:33 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id 191si36909449wmn.116.2016.03.17.06.30.32
        for <linux-mm@kvack.org>;
        Thu, 17 Mar 2016 06:30:32 -0700 (PDT)
Date: Thu, 17 Mar 2016 13:30:22 +0000
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH 1/2] mm/vmap: Add a notifier for when we run out of vmap
 address space
Message-ID: <20160317133022.GW14143@nuc-i3427.alporthouse.com>
References: <1458215982-13405-1-git-send-email-chris@chris-wilson.co.uk>
 <CACZ9PQX+E2LscOGyVQ4xZNK3qdYYotq4HiyGc8o+YwoNi-w1Hg@mail.gmail.com>
 <20160317125736.GT14143@nuc-i3427.alporthouse.com>
 <CACZ9PQWMr4bU3ao46MF6dab2fhTDwL7g59iR0AcpbSPm91qD4g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACZ9PQWMr4bU3ao46MF6dab2fhTDwL7g59iR0AcpbSPm91qD4g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Peniaev <r.peniaev@gmail.com>
Cc: intel-gfx@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Mar 17, 2016 at 02:21:40PM +0100, Roman Peniaev wrote:
> On Thu, Mar 17, 2016 at 1:57 PM, Chris Wilson <chris@chris-wilson.co.uk> wrote:
> > On Thu, Mar 17, 2016 at 01:37:06PM +0100, Roman Peniaev wrote:
> >> > +       freed = 0;
> >> > +       blocking_notifier_call_chain(&vmap_notify_list, 0, &freed);
> >>
> >> It seems to me that alloc_vmap_area() was designed not to sleep,
> >> at least on GFP_NOWAIT path (__GFP_DIRECT_RECLAIM is not set).
> >>
> >> But blocking_notifier_call_chain() might sleep.
> >
> > Indeed, I had not anticipated anybody using GFP_ATOMIC or equivalently
> > restrictive gfp_t for vmap and yes there are such callers.
> >
> > Would guarding the notifier with gfp & __GFP_DIRECT_RECLAIM and
> > !(gfp & __GFP_NORETRY) == be sufficient? Is that enough for GFP_NOFS?
> 
> I would use gfpflags_allow_blocking() for that purpose.

Thanks,
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
