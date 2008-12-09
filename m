Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id mB9CQ9MI023867
	for <linux-mm@kvack.org>; Tue, 9 Dec 2008 23:26:09 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB9CS5iA315564
	for <linux-mm@kvack.org>; Tue, 9 Dec 2008 23:28:05 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB9CRXP7030443
	for <linux-mm@kvack.org>; Tue, 9 Dec 2008 23:27:34 +1100
Date: Tue, 9 Dec 2008 17:57:31 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 4/6] Flat hierarchical reclaim by ID
Message-ID: <20081209122731.GB4174@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com> <20081209200915.41917722.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081209200915.41917722.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-09 20:09:15]:

> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Implement hierarchy reclaim by cgroup_id.
> 
> What changes:
> 	- Page reclaim is not done by tree-walk algorithm
> 	- mem_cgroup->last_schan_child is changed to be ID, not pointer.
> 	- no cgroup_lock, done under RCU.
> 	- scanning order is just defined by ID's order.
> 	  (Scan by round-robin logic.)
> 
> Changelog: v3 -> v4
> 	- adjusted to changes in base kernel.
> 	- is_acnestor() is moved to other patch.
> 
> Changelog: v2 -> v3
> 	- fixed use_hierarchy==0 case
> 
> Changelog: v1 -> v2
> 	- make use of css_tryget();
> 	- count # of loops rather than remembering position.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujisu.com>

I have not yet run the patch, but the heuristics seem a lot like
magic. I am not against scanning by order, but is order the right way
to scan groups? Does this order reflect their position in the
hierarchy? Shouldn't id's belong to cgroups instead of just memory
controller? I would push back ids to cgroups infrastructure.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
