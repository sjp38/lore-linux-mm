Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 354E86B006C
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:03:49 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id n12so3681189wgh.22
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:03:48 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hr5si7603521wjb.150.2014.12.10.06.03.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 06:03:48 -0800 (PST)
Date: Wed, 10 Dec 2014 14:03:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: page_alloc: place zone id check before
 VM_BUG_ON_PAGE check
Message-ID: <20141210140344.GF21903@suse.de>
References: <000001d01383$8e0f1120$aa2d3360$%yang@samsung.com>
 <20141209095922.GB21903@suse.de>
 <CAL1ERfOxEJGJjZk9O_NKV82mOT+udto0tL2eCagicLig6CaJ=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAL1ERfOxEJGJjZk9O_NKV82mOT+udto0tL2eCagicLig6CaJ=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Weijie Yang <weijie.yang@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Dec 10, 2014 at 09:38:42PM +0800, Weijie Yang wrote:
> On Tue, Dec 9, 2014 at 5:59 PM, Mel Gorman <mgorman@suse.de> wrote:
> > On Tue, Dec 09, 2014 at 03:40:35PM +0800, Weijie Yang wrote:
> >> If the free page and its buddy has different zone id, the current
> >> zone->lock cann't prevent buddy page getting allocated, this could
> >> trigger VM_BUG_ON_PAGE in a very tiny chance:
> >>
> >
> > Under what circumstances can a buddy page be allocated without the
> > zone->lock? Any parallel allocation from that zone that takes place will
> > be from the per-cpu allocator and should not be affected by this. Have
> > you actually hit this race?
> 
> My description maybe not clear, if the free page and its buddy is not
> at the same zone, the holding zone->lock cann't prevent buddy page
> getting allocated.

You're right, the description is not clear but now I see your
point. Thanks.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
