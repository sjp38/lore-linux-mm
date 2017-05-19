Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4E62806EA
	for <linux-mm@kvack.org>; Fri, 19 May 2017 12:02:08 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y43so5714283wrc.11
        for <linux-mm@kvack.org>; Fri, 19 May 2017 09:02:08 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id b17si9852482edh.295.2017.05.19.09.02.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 09:02:06 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 5CF0B1C2397
	for <linux-mm@kvack.org>; Fri, 19 May 2017 17:02:06 +0100 (IST)
Date: Fri, 19 May 2017 17:02:05 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v5 02/11] mm: mempolicy: add queue_pages_node_check()
Message-ID: <20170519160205.hkte6tlw26lfn74h@techsingularity.net>
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-3-zi.yan@sent.com>
 <f7a78cb0-0d91-bdbd-4a38-27f94fcefa8a@linux.vnet.ibm.com>
 <16799a52-8a03-7099-5f95-3016808ae65f@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <16799a52-8a03-7099-5f95-3016808ae65f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Zi Yan <zi.yan@sent.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mhocko@kernel.org, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

On Fri, May 19, 2017 at 06:43:37PM +0530, Anshuman Khandual wrote:
> On 04/21/2017 09:34 AM, Anshuman Khandual wrote:
> > On 04/21/2017 02:17 AM, Zi Yan wrote:
> >> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >>
> >> Introduce a separate check routine related to MPOL_MF_INVERT flag.
> >> This patch just does cleanup, no behavioral change.
> > 
> > Can you please send it separately first, this should be debated
> > and merged quickly and not hang on to the series if we have to
> > respin again.
> > 
> > Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> 
> Mel/Andrew,
> 
> This does not have any functional changes and very much independent.
> Can this clean up be accepted as is ? In that case we will have to
> carry one less patch in the series which can make the review process
> simpler.
> 

As you say, there is no functional change but the helper name is vague
and gives no hint to what's it's checking for. It's somewhat tolerable as
it is as it's obvious what is being checked but the same is not true with
the helper name.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
