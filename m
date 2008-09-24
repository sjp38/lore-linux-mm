Received: from d03relay04 (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8OG6it4006065
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 12:06:44 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04 (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8OG6fOm175402
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 10:06:41 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8OG6bW5002094
	for <linux-mm@kvack.org>; Wed, 24 Sep 2008 10:06:41 -0600
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in
	/proc/pid/smaps
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080924154120.GA10837@csn.ul.ie>
References: <20080923211140.DC16.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080923194655.GA25542@csn.ul.ie>
	 <20080924210309.8C3B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080924154120.GA10837@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 24 Sep 2008 09:06:35 -0700
Message-Id: <1222272395.15523.3.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-09-24 at 16:41 +0100, Mel Gorman wrote:
> I admit it's ppc64-specific. In the latest patch series, I made this a
> separate patch so that it could be readily dropped again for this reason.
> Maybe an alternative would be to display MMUPageSize *only* where it differs
> from KernelPageSize. Would that be better or similarly confusing?

I would also think that any arch implementing fallback from large to
small pages in a hugetlbfs area (Adam needs to post his patches :) would
also use this.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
