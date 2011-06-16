Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E34E96B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:46:28 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5GIYarj008000
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:34:36 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5GIkLRK156610
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:46:21 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5GCkAt7003908
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 06:46:11 -0600
Subject: Re: mmotm 2011-06-15-16-56 uploaded (mm/page_cgroup.c)
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110616165146.GB5244@suse.de>
References: <201106160034.p5G0Y4dr028904@imap1.linux-foundation.org>
	 <20110615214917.a7dce8e6.randy.dunlap@oracle.com>
	 <20110616172819.1e2d325c.kamezawa.hiroyu@jp.fujitsu.com>
	 <20110616103559.GA5244@suse.de> <1308241542.11430.119.camel@nimitz>
	 <20110616165146.GB5244@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Jun 2011 11:46:04 -0700
Message-ID: <1308249964.11430.157.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, 2011-06-16 at 17:51 +0100, Mel Gorman wrote:
> No, why was node_start_pfn() and node_end_pfn() defined optionally
> on a per-architecture basis?

Probably because it started in the NUMA-Q port, and we were still trying
to stay off the radar at that point.  It looks like it showed up in
~2.5.[3-4]?.  We didn't know what the heck we were doing back then, and
it probably leaked out from under CONFIG_NUMA/DISCONTIGMEM at some
point.

Seems like a good thing to consolidate to me.  Especially since it's
just a shortcut to the (unconditionally defined) structure member, I
can't see a real justification for needing different definitions.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
