Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB2CC28071E
	for <linux-mm@kvack.org>; Fri, 19 May 2017 16:28:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w79so16117243wme.7
        for <linux-mm@kvack.org>; Fri, 19 May 2017 13:28:45 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id j187si25983258wmd.5.2017.05.19.13.28.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 13:28:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 09CAD989FA
	for <linux-mm@kvack.org>; Fri, 19 May 2017 20:28:44 +0000 (UTC)
Date: Fri, 19 May 2017 21:28:43 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v5 02/11] mm: mempolicy: add queue_pages_node_check()
Message-ID: <20170519202843.lco2rkkivh2a433k@techsingularity.net>
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-3-zi.yan@sent.com>
 <f7a78cb0-0d91-bdbd-4a38-27f94fcefa8a@linux.vnet.ibm.com>
 <16799a52-8a03-7099-5f95-3016808ae65f@linux.vnet.ibm.com>
 <20170519160205.hkte6tlw26lfn74h@techsingularity.net>
 <35E3E5BA-2745-4710-A348-B6E5D892DA27@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <35E3E5BA-2745-4710-A348-B6E5D892DA27@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mhocko@kernel.org, dnellans@nvidia.com

On Fri, May 19, 2017 at 12:37:38PM -0400, Zi Yan wrote:
> > As you say, there is no functional change but the helper name is vague
> > and gives no hint to what's it's checking for. It's somewhat tolerable as
> > it is as it's obvious what is being checked but the same is not true with
> > the helper name.
> >
> 
> Does queue_pages_invert_nodemask_check() work? I can change the helper name
> in the next version.
> 

Not particularly, maybe queue_pages_required and invert the check with a
comment above it explaining what it's checking for would be ok.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
