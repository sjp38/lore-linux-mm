Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1406E6B009F
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 20:22:52 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o251Mo2F016622
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Mar 2010 10:22:50 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DB25845DE59
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 10:22:49 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B196F45DE54
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 10:22:49 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F5DCEF8004
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 10:22:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D68BE38003
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 10:22:49 +0900 (JST)
Date: Fri, 5 Mar 2010 10:19:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/RFC 0/8] Numa: Use Generic Per-cpu Variables for
 numa_*_id()
Message-Id: <20100305101912.f0a875df.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
References: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 04 Mar 2010 12:06:54 -0500
Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:

> >nid-04:
> >
> >* Isn't #define numa_mem numa_node a bit dangerous?  Someone might use
> >  numa_mem as a local variable name.  Why not define it as a inline
> >  function or at least a macro which takes argument.
> 
> numa_mem and numa_node are the names of the per cpu variables, referenced
> by __this_cpu_read().  So, I suppose we can rename them both something like:
> percpu_numa_*.  Would satisfy your concern?
> 
> What do others think?
> 
> Currently I've left them as numa_mem and numa_node.
> 

Could you add some documentation to Documentation/vm/numa ?
about
  numa_node_id()
  numa_mem_id()
  topics on memory-less node
  (cpu-less node)
  

Recently I see this kind of topics on list but I'm not sure whether
I catch the issues/changes correctly....

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
