Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9QFqKAs014420
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 11:52:20 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9QFqJlM098094
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 09:52:20 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9QFqILg007746
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 09:52:19 -0600
Subject: Re: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071026095043.GA14347@skynet.ie>
References: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com>
	 <1193331162.4039.141.camel@localhost>
	 <1193332042.9894.10.camel@dyn9047017100.beaverton.ibm.com>
	 <1193332528.4039.156.camel@localhost>
	 <1193333766.9894.16.camel@dyn9047017100.beaverton.ibm.com>
	 <20071025180514.GB20345@skynet.ie> <1193335935.24087.22.camel@localhost>
	 <20071026095043.GA14347@skynet.ie>
Content-Type: text/plain
Date: Fri, 26 Oct 2007 08:52:16 -0700
Message-Id: <1193413936.24087.91.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-10-26 at 10:50 +0100, Mel Gorman wrote:
> I think that's overkill, especially as any awkward page would give the
> section a score of 0. 

But, if we have a choice, shouldn't we go for a section that is
completely free instead of one that has pages that need some kind of
reclaim first?

We also don't have to have awkward pages keep giving a 0 score, as long
as we have _some_ way of reclaiming them.  If we can't reclaim them,
then I think it *needs* to be 0.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
