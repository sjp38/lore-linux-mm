Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB80280250
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 05:21:12 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gg9so22583831pac.6
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 02:21:12 -0700 (PDT)
Received: from mail-pf0-f193.google.com (mail-pf0-f193.google.com. [209.85.192.193])
        by mx.google.com with ESMTPS id e191si7867887pfg.108.2016.10.07.02.21.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 02:21:11 -0700 (PDT)
Received: by mail-pf0-f193.google.com with SMTP id 190so2577833pfv.1
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 02:21:11 -0700 (PDT)
Date: Fri, 7 Oct 2016 11:21:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, compaction: allow compaction for GFP_NOFS
 requests
Message-ID: <20161007092107.GJ18439@dhcp22.suse.cz>
References: <20161004081215.5563-1-mhocko@kernel.org>
 <e7dc1e23-10fe-99de-e9c8-581857e3ab9d@suse.cz>
 <20161007065019.GA18439@dhcp22.suse.cz>
 <b32db10d-3a89-b60e-ac2c-238484610d8c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b32db10d-3a89-b60e-ac2c-238484610d8c@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 07-10-16 10:15:07, Vlastimil Babka wrote:
> On 10/07/2016 08:50 AM, Michal Hocko wrote:
> > On Fri 07-10-16 07:27:37, Vlastimil Babka wrote:
[...]
> > > But make sure you don't break kcompactd and manual compaction from /proc, as
> > > they don't currently set cc->gfp_mask. Looks like until now it was only used
> > > to determine direct compactor's migratetype which is irrelevant in those
> > > contexts.
> > 
> > OK, I see. This is really subtle. One way to go would be to provide a
> > fake gfp_mask for them. How does the following look to you?
> 
> Looks OK. I'll have to think about the kcompactd case, as gfp mask implying
> unmovable migratetype might restrict it without good reason. But that would
> be separate patch anyway, yours doesn't change that (empty gfp_mask also
> means unmovable migratetype) and that's good.

OK, I see. A follow up patch would be really trivial AFAICS. Just add
__GFP_MOVABLE to the mask. But I am not familiar with all these details
enough to propose a patch with full description.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
