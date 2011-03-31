Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E615A8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 18:27:03 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2VM23dc029765
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 18:02:03 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B834238C804A
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 18:26:47 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2VMQsbK463696
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 18:26:54 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2VMQqsg026522
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 16:26:54 -0600
Subject: Re: [PATCH 04/12] mm: alloc_contig_freed_pages() added
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <op.vs8awkrx3l0zgt@mnazarewicz-glaptop>
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
	 <1301577368-16095-5-git-send-email-m.szyprowski@samsung.com>
	 <1301587083.31087.1032.camel@nimitz>
	 <op.vs77qfx03l0zgt@mnazarewicz-glaptop>
	 <1301606078.31087.1275.camel@nimitz>
	 <op.vs8awkrx3l0zgt@mnazarewicz-glaptop>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 31 Mar 2011 15:26:51 -0700
Message-ID: <1301610411.30870.29.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>

On Fri, 2011-04-01 at 00:18 +0200, Michal Nazarewicz wrote:
> On Thu, 31 Mar 2011 23:14:38 +0200, Dave Hansen wrote:
> > We BUG_ON() in bootmem.  Basically if we try to allocate an early-boot
> > structure and fail, we're screwed.  We can't keep running without an
> > inode hash, or a mem_map[].
> >
> > This looks like it's going to at least get partially used in drivers, at
> > least from the examples.  Are these kinds of things that, if the driver
> > fails to load, that the system is useless and hosed?  Or, is it
> > something where we might limp along to figure out what went wrong before
> > we reboot?
> 
> Bug in the above place does not mean that we could not allocate memory.  It
> means caller is broken.

Could you explain that a bit?

Is this a case where a device is mapped to a very *specific* range of
physical memory and no where else?  What are the reasons for not marking
it off limits at boot?  I also saw some bits of isolation and migration
in those patches.  Can't the migration fail?  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
