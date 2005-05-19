Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4JGtqbS021822
	for <linux-mm@kvack.org>; Thu, 19 May 2005 12:55:52 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4JGtqW5098322
	for <linux-mm@kvack.org>; Thu, 19 May 2005 12:55:52 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4JGtquh004262
	for <linux-mm@kvack.org>; Thu, 19 May 2005 12:55:52 -0400
Date: Thu, 19 May 2005 09:49:30 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: [ckrm-tech] [Patch 5/6] CKRM: Add config support for mem controller
Message-ID: <20050519164930.GG27270@chandralinux.beaverton.ibm.com>
References: <20050519003324.GA25265@chandralinux.beaverton.ibm.com> <1116466010.26955.102.camel@localhost> <20050519162653.GB27270@chandralinux.beaverton.ibm.com> <1116520990.26955.133.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1116520990.26955.133.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 19, 2005 at 09:43:10AM -0700, Dave Hansen wrote:
> On Thu, 2005-05-19 at 09:26 -0700, Chandra Seetharaman wrote:
> > On Wed, May 18, 2005 at 06:26:50PM -0700, Dave Hansen wrote:
> > > There appears to still be some serious issues in the patch with respect
> > > to per-zone accounting.  There is only accounting in each ckrm_mem_res
> > > for each *kind* of zone, not each zone.
> > 
> > In the absense of NUMA/DISCONTIGMEM, isn't 'kind of zone' and 'zone'
> > the same ? Correct me if this assumption is wrong.
> 
> Yes, that is correct.  Do you not expect your code to work with NUMA or
> DISCONTIGMEM?

not yet...
> 
> > > Could you explain what advantages keeping a per-zone-type count has over
> > > actually doing one count for each zone?  Also, why bother tracking it
> > > per-zone-type anyway?  Would a single count work the same way
> > 
> > fits the NUMA/DISCONTIGMEM issue discussed above.
> 
> I don't think it fits it very well, it kinda just glosses over it.  A
> great fit would be something that tracked how much each class was using
> in each zone, not each kind of zone.  Perhaps a controller would like to
> keep an individual class from using too much memory in any particular
> NUMA node.  The current memory controller design would keep that from
> happening.

This is one of "things to consider" in our "numa support".
> 
> -- Dave
> 

-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
