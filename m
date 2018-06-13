Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4BBB06B0005
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 04:37:12 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id s3-v6so1106547plp.21
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 01:37:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5-v6si2389418pfb.244.2018.06.13.01.37.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jun 2018 01:37:10 -0700 (PDT)
Date: Wed, 13 Jun 2018 10:37:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/madvise: allow MADV_DONTNEED to free memory that is
 MLOCK_ONFAULT
Message-ID: <20180613083707.GE13364@dhcp22.suse.cz>
References: <1528484212-7199-1-git-send-email-jbaron@akamai.com>
 <20180611072005.GC13364@dhcp22.suse.cz>
 <4c4de46d-c55a-99a8-469f-e1e634fb8525@akamai.com>
 <20180611150330.GQ13364@dhcp22.suse.cz>
 <775adf2d-140c-1460-857f-2de7b24bafe7@akamai.com>
 <20180612074646.GS13364@dhcp22.suse.cz>
 <5a9398f4-453c-5cb5-6bbc-f20c3affc96a@akamai.com>
 <0daccb7c-f642-c5ce-ca7a-3b3e69025a1e@suse.cz>
 <20180613071552.GD13364@dhcp22.suse.cz>
 <5eb9a018-d5ac-5732-04f1-222c343b840a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5eb9a018-d5ac-5732-04f1-222c343b840a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Jason Baron <jbaron@akamai.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org, emunson@mgebm.net

On Wed 13-06-18 09:51:23, Vlastimil Babka wrote:
> On 06/13/2018 09:15 AM, Michal Hocko wrote:
> > On Wed 13-06-18 08:32:19, Vlastimil Babka wrote:
[...]
> >> I think more concerning than guaranteeing no later major fault is
> >> possible data loss, e.g. replacing data with zero-filled pages.
> > 
> > But MADV_DONTNEED is an explicit call for data loss. Or do I miss your
> > point?
> 
> My point is that if somebody is relying on MADV_DONTNEED not affecting
> mlocked pages, the consequences will be unexpected data loss, not just
> extra page faults.

OK, I see your point now. I would consider this an application bug
though. Calling MADV_DONTNEED and wondering that the content is gone is,
ehm, questionable at best. Why would anybody do that in the first place?

Anyway, I think that we cannot change the behavior because of mlockall
semantic as mentioned earlier.
-- 
Michal Hocko
SUSE Labs
