Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9C64A6B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 19:34:07 -0400 (EDT)
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
 failures V2
From: reinette chatre <reinette.chatre@intel.com>
In-Reply-To: <20091027104017.GC8900@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
	 <1256226219.21134.1493.camel@rc-desk>  <20091027104017.GC8900@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 27 Oct 2009 16:34:05 -0700
Message-Id: <1256686445.21134.10091.camel@rc-desk>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Abbas, Mohamed" <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-10-27 at 03:40 -0700, Mel Gorman wrote:
> On Thu, Oct 22, 2009 at 08:43:38AM -0700, reinette chatre wrote:
> > On Thu, 2009-10-22 at 07:22 -0700, Mel Gorman wrote:
> > > [Bug #14141] order 2 page allocation failures in iwlagn
> > > 	Commit 4752c93c30441f98f7ed723001b1a5e3e5619829 introduced GFP_ATOMIC
> > > 	allocations within the wireless driver. This has caused large numbers
> > > 	of failure reports to occur as reported by Frans Pop. Fixing this
> > > 	requires changes to the driver if it wants to use GFP_ATOMIC which
> > > 	is in the hands of Mohamed Abbas and Reinette Chatre. However,
> > > 	it is very likely that it has being compounded by core mm changes
> > > 	that this series is aimed at.
> > 
> > Driver has been changed to allocate paged skb for its receive buffers.
> > This reduces amount of memory needed from order-2 to order-1. This work
> > is significant and will thus be in 2.6.33. 
> > 
> 
> What do you want to do for -stable in 2.6.31?
> 

I have just posted two patches to stable. The first is to address a bug
in which buffer loss occurs when there is an allocation failure and the
second is what Frans has been testing that reduces the noise when these
allocations fail. They are:

  iwlwifi: fix potential rx buffer lossA-A-A-A-A-A-A-
de0bd50845eb5935ce3d503c5d2f565d6cb9ece1 in linux-2.6
  iwlwifi: reduce noise when skb allocation fails
A-A-A-A-A-A-A-f82a924cc88a5541df1d4b9d38a0968cd077a051 in linux-2.6

Reinette


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
