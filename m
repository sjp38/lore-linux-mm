Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 443176B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 21:11:22 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id x63so34919214pfx.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 18:11:22 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f4si9024669pgc.224.2017.03.02.18.11.20
        for <linux-mm@kvack.org>;
        Thu, 02 Mar 2017 18:11:21 -0800 (PST)
Date: Fri, 3 Mar 2017 11:11:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 00/11] make try_to_unmap simple
Message-ID: <20170303021118.GA3503@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <86c860e4-c53d-200a-f36a-2ed8a7415d5d@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86c860e4-c53d-200a-f36a-2ed8a7415d5d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

Hi Anshuman,

On Thu, Mar 02, 2017 at 07:52:27PM +0530, Anshuman Khandual wrote:
> On 03/02/2017 12:09 PM, Minchan Kim wrote:
> > Currently, try_to_unmap returns various return value(SWAP_SUCCESS,
> > SWAP_FAIL, SWAP_AGAIN, SWAP_DIRTY and SWAP_MLOCK). When I look into
> > that, it's unncessary complicated so this patch aims for cleaning
> > it up. Change ttu to boolean function so we can remove SWAP_AGAIN,
> > SWAP_DIRTY, SWAP_MLOCK.
> 
> It may be a trivial question but apart from being a cleanup does it
> help in improving it's callers some way ? Any other benefits ?

If you mean some performace, I don't think so. It just aims for cleanup
so caller don't need to think much about return value of try_to_unmap.
What he should consider is just "success/fail". Others will be done in
isolate/putback friends which makes API simple/easy to use.

Thanks.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
