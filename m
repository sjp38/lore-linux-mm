Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EEE486B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 14:34:44 -0400 (EDT)
Date: Mon, 24 May 2010 11:34:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/7]
 numa-x86_64-use-generic-percpu-var-numa_node_id-implementation-fix1
Message-Id: <20100524113401.e95aafd5.akpm@linux-foundation.org>
In-Reply-To: <1274712112.13756.177.camel@useless.americas.hpqcorp.net>
References: <20100503150455.15039.10178.sendpatchset@localhost.localdomain>
	<20100503150518.15039.3576.sendpatchset@localhost.localdomain>
	<20100521160240.b61d3404.akpm@linux-foundation.org>
	<1274710172.13756.122.camel@useless.americas.hpqcorp.net>
	<144644.1274710321@localhost>
	<1274712112.13756.177.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Valdis.Kletnieks@vt.edu, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Randy Dunlap <randy.dunlap@oracle.com>, Christoph Lameter <cl@linux-foundation.org>, eric.whitney@hp.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 24 May 2010 10:41:52 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> On Mon, 2010-05-24 at 10:12 -0400, Valdis.Kletnieks@vt.edu wrote:
> > On Mon, 24 May 2010 10:09:32 EDT, Lee Schermerhorn said:
> > > 
> > > You asked about the fix3 patch [offlist] on Wednesday, 19May.  Do you
> > > have that one in your tree?
> >  
> > numa-introduce-numa_mem_id-effective-local-memory-node-id-fix3.patch
> > was in -mmotm0521.
> 
> Right.  But, Andrew needs:
> numa-x86_64-use-generic-percpu-var-numa_node_id-implementation-fix3 --
> i.e., a fix to the 2nd patch of the percpu numa_*_id patch series.
> 

blah.

I have a
numa-x86_64-use-generic-percpu-var-numa_node_id-implementation-fix1.patch
and a fix3.  Was there ever a fix2?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
