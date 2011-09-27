Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AE5F59000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 21:05:24 -0400 (EDT)
Subject: Re: [patch]mm: initialize zone all_unreclaimable
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110926155250.464e7770.akpm@google.com>
References: <1317024712.29510.178.camel@sli10-conroe>
	 <20110926132320.GA4206@tiehlicka.suse.cz>
	 <20110926155250.464e7770.akpm@google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 27 Sep 2011 09:10:11 +0800
Message-ID: <1317085811.29510.180.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2011-09-27 at 06:52 +0800, Andrew Morton wrote:
> On Mon, 26 Sep 2011 15:23:20 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Mon 26-09-11 16:11:52, Shaohua Li wrote:
> > > I saw DMA zone is always unreclaimable in my system. 
> > > zone->all_unreclaimable isn't initialized till a page from the zone is
> > > freed. This isn't a big problem normally, but a little confused, so
> > > fix here.
> > 
> > The value is initialized when a node is allocated. setup_node_data uses
> > alloc_remap which memsets the whole structure or memblock allocation
> > which is initialized to 0 as well AFAIK and memory hotplug uses
> > arch_alloc_nodedata which is kzalloc.
> 
> setup_node_data() does memset(NODE_DATA(nid), 0, sizeof(pg_data_t)) just
> to be sure.
> 
> However, Shaohua reports that "DMA zone is always unreclaimable in my system",
> and presumably this patch fixed it.  So we don't know what's going on?
> 
> 
> 
> Presumably all the other "zone->foo = 0" assignments in free_area_init_core()
> are unneeded.
Looks I didn't run my test correctly, sorry. I just check it, and this
is a vmscan bug, I'll work out a new patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
