Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id F225F28073B
	for <linux-mm@kvack.org>; Fri, 19 May 2017 17:39:15 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o52so6748202wrb.10
        for <linux-mm@kvack.org>; Fri, 19 May 2017 14:39:15 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id 199si11438095wms.154.2017.05.19.14.39.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 14:39:13 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 526D12F80C3
	for <linux-mm@kvack.org>; Fri, 19 May 2017 21:39:13 +0000 (UTC)
Date: Fri, 19 May 2017 22:39:12 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v5 02/11] mm: mempolicy: add queue_pages_node_check()
Message-ID: <20170519213912.xm6zuucby3h6ne6r@techsingularity.net>
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-3-zi.yan@sent.com>
 <f7a78cb0-0d91-bdbd-4a38-27f94fcefa8a@linux.vnet.ibm.com>
 <16799a52-8a03-7099-5f95-3016808ae65f@linux.vnet.ibm.com>
 <20170519160205.hkte6tlw26lfn74h@techsingularity.net>
 <35E3E5BA-2745-4710-A348-B6E5D892DA27@cs.rutgers.edu>
 <20170519202843.lco2rkkivh2a433k@techsingularity.net>
 <61FCE04A-0227-4D5E-92E5-81EA06979FD3@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <61FCE04A-0227-4D5E-92E5-81EA06979FD3@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mhocko@kernel.org, dnellans@nvidia.com

On Fri, May 19, 2017 at 04:48:54PM -0400, Zi Yan wrote:
> On 19 May 2017, at 16:28, Mel Gorman wrote:
> 
> > On Fri, May 19, 2017 at 12:37:38PM -0400, Zi Yan wrote:
> >>> As you say, there is no functional change but the helper name is vague
> >>> and gives no hint to what's it's checking for. It's somewhat tolerable as
> >>> it is as it's obvious what is being checked but the same is not true with
> >>> the helper name.
> >>>
> >>
> >> Does queue_pages_invert_nodemask_check() work? I can change the helper name
> >> in the next version.
> >>
> >
> > Not particularly, maybe queue_pages_required and invert the check with a
> > comment above it explaining what it's checking for would be ok.
> >
> 
> queue_pages_required() is too broad,

I'm somewhat amused that you'd complain that "required" is too broad while
thinking "check" is somehow self-explanatory.

> I would take queue_pages_page_nid_check()
> and invert the check with a comment above saying
> 
> /*
>  * Check if the page's nid is in qp->nmask.
>  *
>  * If MPOL_MF_INVERT is set in qp->flags, check if the nid is
>  * in the invert of qp->nmask.
>  */
> 
> Does it work?
> 

I still don't like the name but I also am not interested in debating it
further for something so small. Add the comment, it's better than nothing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
