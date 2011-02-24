Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6738C8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 05:09:10 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3ABE23EE0BB
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 19:09:03 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 24E3945DE5B
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 19:09:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CCF745DE58
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 19:09:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F231EE38005
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 19:09:02 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BD6D5E38003
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 19:09:02 +0900 (JST)
Date: Thu, 24 Feb 2011 19:02:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM
Message-Id: <20110224190247.bdc2e6f8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110224093519.GB20922@tiehlicka.suse.cz>
References: <20110223151047.GA7275@tiehlicka.suse.cz>
	<1298485162.7236.4.camel@nimitz>
	<20110224085227.1a3e185b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110224093519.GB20922@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 24 Feb 2011 10:35:19 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 24-02-11 08:52:27, KAMEZAWA Hiroyuki wrote:
> > On Wed, 23 Feb 2011 10:19:22 -0800
> > Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> > 
> > > On Wed, 2011-02-23 at 16:10 +0100, Michal Hocko wrote:
> > > > We can reduce this internal fragmentation by splitting the single
> > > > page_cgroup array into more arrays where each one is well kmalloc
> > > > aligned. This patch implements this idea. 
> > > 
> > > How about using alloc_pages_exact()?  These things aren't allocated
> > > often enough to really get most of the benefits of being in a slab.
> > > That'll at least get you down to a maximum of about PAGE_SIZE wasted.  
> > > 
> > 
> > yes, alloc_pages_exact() is much better.
> > 
> > packing page_cgroups for multiple sections causes breakage in memory hotplug logic.
> 
> I am not sure I understand this. What do you mean by packing
> page_cgroups for multiple sections? The patch I have posted doesn't do
> any packing. Or do you mean that using a double array can break hotplog?
> Not that this would change anything, alloc_pages_exact is really a
> better solution, I am just curious ;) 
> 

Sorry, it seems I failed to read code correctly. 
You just implemented 2 level table..


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
