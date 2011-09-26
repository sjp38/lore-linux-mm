Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C13339000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:53:06 -0400 (EDT)
Date: Mon, 26 Sep 2011 15:52:50 -0700
From: Andrew Morton <akpm@google.com>
Subject: Re: [patch]mm: initialize zone all_unreclaimable
Message-Id: <20110926155250.464e7770.akpm@google.com>
In-Reply-To: <20110926132320.GA4206@tiehlicka.suse.cz>
References: <1317024712.29510.178.camel@sli10-conroe>
	<20110926132320.GA4206@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 26 Sep 2011 15:23:20 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Mon 26-09-11 16:11:52, Shaohua Li wrote:
> > I saw DMA zone is always unreclaimable in my system. 
> > zone->all_unreclaimable isn't initialized till a page from the zone is
> > freed. This isn't a big problem normally, but a little confused, so
> > fix here.
> 
> The value is initialized when a node is allocated. setup_node_data uses
> alloc_remap which memsets the whole structure or memblock allocation
> which is initialized to 0 as well AFAIK and memory hotplug uses
> arch_alloc_nodedata which is kzalloc.

setup_node_data() does memset(NODE_DATA(nid), 0, sizeof(pg_data_t)) just
to be sure.

However, Shaohua reports that "DMA zone is always unreclaimable in my system",
and presumably this patch fixed it.  So we don't know what's going on?



Presumably all the other "zone->foo = 0" assignments in free_area_init_core()
are unneeded.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
