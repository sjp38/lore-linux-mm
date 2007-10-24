Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9OK0PSm026208
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 16:00:25 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9OK0PwN133344
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 16:00:25 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9OK0O2v023582
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 16:00:25 -0400
Subject: Re: [PATCH 3/3] [PATCH] hugetlb: Enforce quotas during reservation
	for shared mappings
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1193255578.18417.63.camel@localhost.localdomain>
References: <20071024132335.13013.76227.stgit@kernel>
	 <20071024132408.13013.81566.stgit@kernel>
	 <1193252821.4039.33.camel@localhost>
	 <1193255578.18417.63.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 24 Oct 2007 13:00:22 -0700
Message-Id: <1193256022.4039.58.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-24 at 14:52 -0500, Adam Litke wrote:
> 
> > Since alloc_huge_page() gets the VMA it could, in theory, be doing the
> > accounting.  The other user, hugetlb_cow(), seems to have a similar code
> > path.  But, it doesn't have to worry about shared_page, right?  We can
> > only have COWs on MAP_PRIVATE.
> > 
> > I'm just trying to find ways to future-proof the quotas since they
> > already got screwed up once.  The fewer call sites we have for them, the
> > fewer places they can get screwed up. :)
> 
> Yep.  Originally I wanted to put the hugetlb_get_quota() call inside
> alloc_huge_page() but the devil is in the details.  Failure to get quota
> needs to result in a SIGBUS whereas a standard allocation failure is
> OOM.  Because of this, we'd still need special handling of the
> alloc_huge_page() return value.  While that can be done easily enough, I
> didn't think it was worth it.  

Does it need special handling if we just use ERR_PTR()s?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
