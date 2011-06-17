Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C2DE66B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 03:56:10 -0400 (EDT)
Date: Fri, 17 Jun 2011 08:55:55 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: mmotm 2011-06-15-16-56 uploaded (mm/page_cgroup.c)
Message-ID: <20110617075555.GC5244@suse.de>
References: <201106160034.p5G0Y4dr028904@imap1.linux-foundation.org>
 <20110615214917.a7dce8e6.randy.dunlap@oracle.com>
 <20110616172819.1e2d325c.kamezawa.hiroyu@jp.fujitsu.com>
 <20110616103559.GA5244@suse.de>
 <1308241542.11430.119.camel@nimitz>
 <20110616165146.GB5244@suse.de>
 <1308249964.11430.157.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1308249964.11430.157.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, Jun 16, 2011 at 11:46:04AM -0700, Dave Hansen wrote:
> On Thu, 2011-06-16 at 17:51 +0100, Mel Gorman wrote:
> > No, why was node_start_pfn() and node_end_pfn() defined optionally
> > on a per-architecture basis?
> 
> Probably because it started in the NUMA-Q port, and we were still trying
> to stay off the radar at that point.  It looks like it showed up in
> ~2.5.[3-4]?.  We didn't know what the heck we were doing back then, and
> it probably leaked out from under CONFIG_NUMA/DISCONTIGMEM at some
> point.
> 
> Seems like a good thing to consolidate to me.  Especially since it's
> just a shortcut to the (unconditionally defined) structure member, I
> can't see a real justification for needing different definitions.
> 

Great. Thanks Dave.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
