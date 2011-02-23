Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 707C48D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 18:59:09 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0D44B3EE081
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 08:59:04 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E190E45DE51
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 08:59:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C81B745DE4F
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 08:59:03 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B8C291DB8040
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 08:59:03 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 845FB1DB802F
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 08:59:03 +0900 (JST)
Date: Thu, 24 Feb 2011 08:52:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM
Message-Id: <20110224085227.1a3e185b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1298485162.7236.4.camel@nimitz>
References: <20110223151047.GA7275@tiehlicka.suse.cz>
	<1298485162.7236.4.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 23 Feb 2011 10:19:22 -0800
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Wed, 2011-02-23 at 16:10 +0100, Michal Hocko wrote:
> > We can reduce this internal fragmentation by splitting the single
> > page_cgroup array into more arrays where each one is well kmalloc
> > aligned. This patch implements this idea. 
> 
> How about using alloc_pages_exact()?  These things aren't allocated
> often enough to really get most of the benefits of being in a slab.
> That'll at least get you down to a maximum of about PAGE_SIZE wasted.  
> 

yes, alloc_pages_exact() is much better.

packing page_cgroups for multiple sections causes breakage in memory hotplug logic.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
