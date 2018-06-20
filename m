Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 899AA6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 07:00:31 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f7-v6so2241436wrq.19
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 04:00:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m18-v6si1006303edq.440.2018.06.20.04.00.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jun 2018 04:00:27 -0700 (PDT)
Date: Wed, 20 Jun 2018 13:00:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/madvise: allow MADV_DONTNEED to free memory that is
 MLOCK_ONFAULT
Message-ID: <20180620110022.GK13685@dhcp22.suse.cz>
References: <1528484212-7199-1-git-send-email-jbaron@akamai.com>
 <20180611072005.GC13364@dhcp22.suse.cz>
 <4c4de46d-c55a-99a8-469f-e1e634fb8525@akamai.com>
 <20180611150330.GQ13364@dhcp22.suse.cz>
 <775adf2d-140c-1460-857f-2de7b24bafe7@akamai.com>
 <20180612074646.GS13364@dhcp22.suse.cz>
 <5a9398f4-453c-5cb5-6bbc-f20c3affc96a@akamai.com>
 <0daccb7c-f642-c5ce-ca7a-3b3e69025a1e@suse.cz>
 <20180613071552.GD13364@dhcp22.suse.cz>
 <7a671035-92dc-f9c0-aa7b-ff916d556e82@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7a671035-92dc-f9c0-aa7b-ff916d556e82@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Baron <jbaron@akamai.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org, emunson@mgebm.net

On Fri 15-06-18 15:36:07, Jason Baron wrote:
> 
> 
> On 06/13/2018 03:15 AM, Michal Hocko wrote:
> > On Wed 13-06-18 08:32:19, Vlastimil Babka wrote:
[...]
> >> BTW I didn't get why we should allow this for MADV_DONTNEED but not
> >> MADV_FREE. Can you expand on that?
> > 
> > Well, I wanted to bring this up as well. I guess this would require some
> > more hacks to handle the reclaim path correctly because we do rely on
> > VM_LOCK at many places for the lazy mlock pages culling.
> > 
> 
> The point of not allowing MADV_FREE on mlock'd pages for me was that
> with mlock and even MLOCK_ON_FAULT, one can always can always determine
> if a page is present or not (and thus avoid the major fault). Allowing
> MADV_FREE on lock'd pages breaks that assumption.

But once you have called MADV_FREE you cannot assume anything about the
content until you touch the memory again. So you can safely assume a
major fault for the worst case. Btw. why knowing whether you major fault
is important in the first place? What is an application going to do
about that information?
-- 
Michal Hocko
SUSE Labs
