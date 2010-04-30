Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4F96B0232
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 00:59:04 -0400 (EDT)
Message-ID: <4BDA6362.4030505@kernel.org>
Date: Fri, 30 Apr 2010 06:58:10 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/8] numa:  x86_64:  use generic percpu var numa_node_id()
 implementation
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>	 <20100415173003.8801.48519.sendpatchset@localhost.localdomain>	 <alpine.DEB.2.00.1004161144350.8664@router.home>	 <4BCA74D8.3030503@kernel.org> <1272560208.4927.39.camel@useless.americas.hpqcorp.net>
In-Reply-To: <1272560208.4927.39.camel@useless.americas.hpqcorp.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hello,

On 04/29/2010 06:56 PM, Lee Schermerhorn wrote:
> Tejun:  do you mean:
> 
> #ifdef CONFIG_NUMA
>         if (cpu != 0 && percpu_read(numa_node) == 0 &&
> ........................^ here?
>             early_cpu_to_node(cpu) != NUMA_NO_NODE)
>                 set_numa_node(early_cpu_to_node(cpu));
> #endif
> 
> Looks like 'numa_node_id()' would work there.

Yeah, it just looked weird to use raw variable when an access wrapper
is there.

> But, I wonder what the "cpu != 0 && percpu_read(numa_node) == 0" is
> trying to do?

That I have don't have any clue about.  :-)

> Just trying to grok the intent.  Maybe someone will chime in.

Christoph?  Mel?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
