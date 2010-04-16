Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 765FF6B01FF
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 12:47:10 -0400 (EDT)
Date: Fri, 16 Apr 2010 11:46:51 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/8] numa:  x86_64:  use generic percpu var numa_node_id()
 implementation
In-Reply-To: <20100415173003.8801.48519.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1004161144350.8664@router.home>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain> <20100415173003.8801.48519.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi@domain.invalid, Kleen@domain.invalid, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Apr 2010, Lee Schermerhorn wrote:

> x86 arch specific changes to use generic numa_node_id() based on
> generic percpu variable infrastructure.  Back out x86's custom
> version of numa_node_id()
>
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> [Christoph's signoff here?]

Hmmm. Its mostly your work now. Maybe Reviewed-by will be ok?

> @@ -809,7 +806,7 @@ void __cpuinit numa_set_node(int cpu, in
>  	per_cpu(x86_cpu_to_node_map, cpu) = node;
>
>  	if (node != NUMA_NO_NODE)
> -		per_cpu(node_number, cpu) = node;
> +		per_cpu(numa_node, cpu) = node;
>  }

Maybe provide a generic function to set the node for cpu X?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
