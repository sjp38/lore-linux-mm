Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4JGhRLK550594
	for <linux-mm@kvack.org>; Thu, 19 May 2005 12:43:38 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4JGhROG081106
	for <linux-mm@kvack.org>; Thu, 19 May 2005 10:43:27 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4JGhROZ008792
	for <linux-mm@kvack.org>; Thu, 19 May 2005 10:43:27 -0600
Subject: Re: [ckrm-tech] [Patch 5/6] CKRM: Add config support for mem
	controller
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050519162653.GB27270@chandralinux.beaverton.ibm.com>
References: <20050519003324.GA25265@chandralinux.beaverton.ibm.com>
	 <1116466010.26955.102.camel@localhost>
	 <20050519162653.GB27270@chandralinux.beaverton.ibm.com>
Content-Type: text/plain
Date: Thu, 19 May 2005 09:43:10 -0700
Message-Id: <1116520990.26955.133.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chandra Seetharaman <sekharan@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-05-19 at 09:26 -0700, Chandra Seetharaman wrote:
> On Wed, May 18, 2005 at 06:26:50PM -0700, Dave Hansen wrote:
> > There appears to still be some serious issues in the patch with respect
> > to per-zone accounting.  There is only accounting in each ckrm_mem_res
> > for each *kind* of zone, not each zone.
> 
> In the absense of NUMA/DISCONTIGMEM, isn't 'kind of zone' and 'zone'
> the same ? Correct me if this assumption is wrong.

Yes, that is correct.  Do you not expect your code to work with NUMA or
DISCONTIGMEM?

> > Could you explain what advantages keeping a per-zone-type count has over
> > actually doing one count for each zone?  Also, why bother tracking it
> > per-zone-type anyway?  Would a single count work the same way
> 
> fits the NUMA/DISCONTIGMEM issue discussed above.

I don't think it fits it very well, it kinda just glosses over it.  A
great fit would be something that tracked how much each class was using
in each zone, not each kind of zone.  Perhaps a controller would like to
keep an individual class from using too much memory in any particular
NUMA node.  The current memory controller design would keep that from
happening.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
