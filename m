Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8DA196B0036
	for <linux-mm@kvack.org>; Thu,  1 May 2014 11:11:22 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so2333675eek.34
        for <linux-mm@kvack.org>; Thu, 01 May 2014 08:11:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x46si34403303eea.269.2014.05.01.08.11.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 08:11:20 -0700 (PDT)
Date: Thu, 1 May 2014 16:11:16 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/17] mm: page_alloc: Use unsigned int for order in more
 places
Message-ID: <20140501151116.GM23991@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
 <1398933888-4940-12-git-send-email-mgorman@suse.de>
 <53625BC3.3000804@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <53625BC3.3000804@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, May 01, 2014 at 07:35:47AM -0700, Dave Hansen wrote:
> On 05/01/2014 01:44 AM, Mel Gorman wrote:
> > X86 prefers the use of unsigned types for iterators and there is a
> > tendency to mix whether a signed or unsigned type if used for page
> > order. This converts a number of sites in mm/page_alloc.c to use
> > unsigned int for order where possible.
> 
> Does this actually generate any different code?  I'd actually expect
> something like 'order' to be one of the easiest things for the compiler
> to figure out an absolute range on.
> 

Yeah, it generates different code. Considering that this patch affects an
API that can be called external to the code block how would the compiler
know what the range of order would be in all cases?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
