Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 449356B0032
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 04:59:27 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so9566891wiv.0
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 01:59:26 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lj5si1224101wjc.60.2014.12.09.01.59.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 01:59:26 -0800 (PST)
Date: Tue, 9 Dec 2014 09:59:22 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: page_alloc: place zone id check before
 VM_BUG_ON_PAGE check
Message-ID: <20141209095922.GB21903@suse.de>
References: <000001d01383$8e0f1120$aa2d3360$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <000001d01383$8e0f1120$aa2d3360$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Rik van Riel' <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Weijie Yang' <weijie.yang.kh@gmail.com>

On Tue, Dec 09, 2014 at 03:40:35PM +0800, Weijie Yang wrote:
> If the free page and its buddy has different zone id, the current
> zone->lock cann't prevent buddy page getting allocated, this could
> trigger VM_BUG_ON_PAGE in a very tiny chance:
> 

Under what circumstances can a buddy page be allocated without the
zone->lock? Any parallel allocation from that zone that takes place will
be from the per-cpu allocator and should not be affected by this. Have
you actually hit this race?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
