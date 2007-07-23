Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6NJqu43029110
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 15:52:56 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6NJqqb6259656
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 13:52:53 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6NJqpqZ006434
	for <linux-mm@kvack.org>; Mon, 23 Jul 2007 13:52:52 -0600
Subject: Re: [PATCH 1/5] [hugetlb] Introduce BASE_PAGES_PER_HPAGE constant
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20070723124303.27b32989@schroedinger.engr.sgi.com>
References: <20070713151621.17750.58171.stgit@kernel>
	 <20070713151631.17750.44881.stgit@kernel>
	 <20070723124303.27b32989@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 23 Jul 2007 14:52:51 -0500
Message-Id: <1185220371.12773.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, William Lee Irwin III <wli@holomorphy.com>, Ken Chen <kenchen@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-07-23 at 12:43 -0700, Christoph Lameter wrote:
> On Fri, 13 Jul 2007 08:16:31 -0700
> Adam Litke <agl@us.ibm.com> wrote:
> 
> 
> > In many places throughout the kernel, the expression
> > (HPAGE_SIZE/PAGE_SIZE) is used to convert quantities in huge page
> > units to a number of base pages. Reduce redundancy and make the code
> > more readable by introducing a constant BASE_PAGES_PER_HPAGE whose
> > name more clearly conveys the intended conversion.
> 
> It may be better to put in a generic way of determining the pages of a
> compound page.
> 
> Usually
> 
> 1 << compound_order(page) will do the trick.

Yes, that is much nicer, thanks!

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
