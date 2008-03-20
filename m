Date: Thu, 20 Mar 2008 14:09:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] radix-tree page cgroup
Message-Id: <20080320140943.6d879380.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080320134513.3e4d45f1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314191733.eff648f8.kamezawa.hiroyu@jp.fujitsu.com>
	<1205961066.6437.10.camel@lappy>
	<20080320134513.3e4d45f1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Mar 2008 13:45:13 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

>
> > > +	base_pfn = idx << PCGRP_SHIFT;
> > > +retry:
> > > +	error = 0;
> > > +	rcu_read_lock();
> > > +	head = radix_tree_lookup(&root->root_node, idx);
> > > +	rcu_read_unlock();
> > 
> > This looks iffy, who protects head here?
> > 
> 
> In this patch, a routine for freeing "head" is not included.
> Then....Hmm.....rcu_read_xxx is not required...I'll remove it.
> I'll check the whole logic around here again.
> 
Sorry, I was confused...for radix-tree, ruc_xxx is necessary.

Regards,
-Kame
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
