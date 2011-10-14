Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2FAE36B016A
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 14:26:54 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 14 Oct 2011 14:22:13 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EIM2Pd164778
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 14:22:02 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EIM211022388
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 15:22:02 -0300
Message-ID: <4E987DC7.3000903@linux.vnet.ibm.com>
Date: Fri, 14 Oct 2011 13:21:59 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] staging: zcache: remove zcache_direct_reclaim_lock
References: <1318448460-5930-1-git-send-email-sjenning@linux.vnet.ibm.com> <3e84809b-a45d-4980-b342-c2d671f87f79@default> <4E986B85.6020006@linux.vnet.ibm.com>
In-Reply-To: <4E986B85.6020006@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: gregkh@suse.de, cascardo@holoscopio.com, rdunlap@xenotime.net, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rcj@linux.vnet.ibm.com, brking@linux.vnet.ibm.com

On 10/14/2011 12:04 PM, Seth Jennings wrote:
> On 10/12/2011 03:39 PM, Dan Magenheimer wrote:
>>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>>> Subject: [PATCH] staging: zcache: remove zcache_direct_reclaim_lock
> 
> If the preload is called with PF_MEMALLOC set, then 
> the shrinker will not be run during a kmem_cache_alloc().
> 
> However if the preload is called with PF_MEMALLOC being set
Sorry, should have been *without PF_MEMALLOC being set

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
