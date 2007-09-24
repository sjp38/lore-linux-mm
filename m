Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8OGMMw7013281
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 12:22:22 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8OGMMYA416104
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 10:22:22 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8OGMLqw018391
	for <linux-mm@kvack.org>; Mon, 24 Sep 2007 10:22:21 -0600
Date: Mon, 24 Sep 2007 09:22:20 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 1/4] hugetlb: search harder for memory in alloc_fresh_huge_page()
Message-ID: <20070924162220.GA26104@us.ibm.com>
References: <20070906182134.GA7779@us.ibm.com> <20070914172638.GT24941@us.ibm.com> <Pine.LNX.4.64.0709141041390.15683@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0709141041390.15683@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: wli@holomorphy.com, agl@us.ibm.com, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.09.2007 [10:43:20 -0700], Christoph Lameter wrote:
> On Fri, 14 Sep 2007, Nishanth Aravamudan wrote:
> 
> > Christoph, Lee, ping? I haven't heard any response on these patches this
> > time around. Would it be acceptable to ask Andrew to pick them up for
> > the next -mm?
> 
> I am sorry but there is some churn already going on with other core
> memory management patches. Could we hold this off until the dust
> settles on those and then rebase?

Yes, I'll keep tracking -mm with my series. I wonder, though, if it
would be possible to at least get the bugfixes for memoryless nodes in
hugetlb code (patches 1 and 2) in to -mm sooner rather than later (I can
fix your issues with the static variable, I hope). The other two patches
are more feature-like, so can be postponed for now.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
