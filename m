Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 040BE6B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 06:40:23 -0400 (EDT)
Date: Tue, 27 Oct 2009 10:40:17 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Message-ID: <20091027104017.GC8900@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256226219.21134.1493.camel@rc-desk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1256226219.21134.1493.camel@rc-desk>
Sender: owner-linux-mm@kvack.org
To: reinette chatre <reinette.chatre@intel.com>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Abbas, Mohamed" <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 22, 2009 at 08:43:38AM -0700, reinette chatre wrote:
> On Thu, 2009-10-22 at 07:22 -0700, Mel Gorman wrote:
> > [Bug #14141] order 2 page allocation failures in iwlagn
> > 	Commit 4752c93c30441f98f7ed723001b1a5e3e5619829 introduced GFP_ATOMIC
> > 	allocations within the wireless driver. This has caused large numbers
> > 	of failure reports to occur as reported by Frans Pop. Fixing this
> > 	requires changes to the driver if it wants to use GFP_ATOMIC which
> > 	is in the hands of Mohamed Abbas and Reinette Chatre. However,
> > 	it is very likely that it has being compounded by core mm changes
> > 	that this series is aimed at.
> 
> Driver has been changed to allocate paged skb for its receive buffers.
> This reduces amount of memory needed from order-2 to order-1. This work
> is significant and will thus be in 2.6.33. 
> 

What do you want to do for -stable in 2.6.31?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
