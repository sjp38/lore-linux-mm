Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31B006B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 22:04:19 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j5so103567862pfb.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 19:04:19 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w31si9183140pla.116.2017.03.02.19.04.17
        for <linux-mm@kvack.org>;
        Thu, 02 Mar 2017 19:04:18 -0800 (PST)
Date: Fri, 3 Mar 2017 12:04:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 04/11] mm: remove SWAP_MLOCK check for SWAP_SUCCESS in ttu
Message-ID: <20170303030416.GF3503@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-5-git-send-email-minchan@kernel.org>
 <65fd1dd1-7ca4-6610-285c-09436879d8ed@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <65fd1dd1-7ca4-6610-285c-09436879d8ed@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On Thu, Mar 02, 2017 at 08:21:46PM +0530, Anshuman Khandual wrote:
> On 03/02/2017 12:09 PM, Minchan Kim wrote:
> > If the page is mapped and rescue in ttuo, page_mapcount(page) == 0 cannot
> 
> Nit: "ttuo" is very cryptic. Please expand it.

No problem.

> 
> > be true so page_mapcount check in ttu is enough to return SWAP_SUCCESS.
> > IOW, SWAP_MLOCK check is redundant so remove it.
> 
> Right, page_mapcount(page) should be enough to tell whether swapping
> out happened successfully or the page is still mapped in some page
> table.
> 

Thanks for the review, Anshuman!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
