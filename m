Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C7FC56B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 10:57:54 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g23so38785617wme.4
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 07:57:54 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id g78si8990168wme.5.2016.12.07.07.57.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 07:57:53 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 9F34C1C1B3A
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 15:57:51 +0000 (GMT)
Date: Wed, 7 Dec 2016 15:57:50 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
Message-ID: <20161207155750.yfsizliaoodks5k4@techsingularity.net>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
 <alpine.DEB.2.20.1612070849260.8398@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1612070849260.8398@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Dec 07, 2016 at 08:52:27AM -0600, Christoph Lameter wrote:
> On Wed, 7 Dec 2016, Mel Gorman wrote:
> 
> > SLUB has been the default small kernel object allocator for quite some time
> > but it is not universally used due to performance concerns and a reliance
> > on high-order pages. The high-order concerns has two major components --
> 
> SLUB does not rely on high order pages. It falls back to lower order if
> the higher orders are not available. Its a performance concern.
> 

Ok -- While SLUB does not rely on high-order pages for functional
correctness, it perfoms better if high-order pages are available.

> This is also an issue for various other kernel subsystems that really
> would like to have larger contiguous memory area. We are often seeing
> performance constraints due to the high number of 4k segments when doing
> large scale block I/O f.e.
> 

Which is related to the fundamentals of fragmentation control in
general. At some point there will have to be a revisit to get back to
the type of reliability that existed in 3.0-era without the massive
overhead it incurred. As stated before, I agree it's important but
outside the scope of this patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
