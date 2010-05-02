Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4B4AF6004C0
	for <linux-mm@kvack.org>; Sat,  1 May 2010 21:53:56 -0400 (EDT)
Date: Sat, 1 May 2010 20:49:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/8] numa:  x86_64:  use generic percpu var numa_node_id()
 implementation
In-Reply-To: <4BDA6362.4030505@kernel.org>
Message-ID: <alpine.DEB.2.00.1005012048220.2663@router.home>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>  <20100415173003.8801.48519.sendpatchset@localhost.localdomain>  <alpine.DEB.2.00.1004161144350.8664@router.home>  <4BCA74D8.3030503@kernel.org> <1272560208.4927.39.camel@useless.americas.hpqcorp.net>
 <4BDA6362.4030505@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 30 Apr 2010, Tejun Heo wrote:

> Hello,
>
> On 04/29/2010 06:56 PM, Lee Schermerhorn wrote:
> > Tejun:  do you mean:
> >
> > #ifdef CONFIG_NUMA
> >         if (cpu != 0 && percpu_read(numa_node) == 0 &&
> > ........................^ here?
> >             early_cpu_to_node(cpu) != NUMA_NO_NODE)
> >                 set_numa_node(early_cpu_to_node(cpu));
> > #endif
> >
> > Looks like 'numa_node_id()' would work there.
>
> Yeah, it just looked weird to use raw variable when an access wrapper
> is there.
>
> > But, I wonder what the "cpu != 0 && percpu_read(numa_node) == 0" is
> > trying to do?
>
> That I have don't have any clue about.  :-)

I guess that cpu 0 is used for booting and its initialized early when
certain functionality is not available yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
