Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3F4FF6B02A3
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 16:20:40 -0400 (EDT)
Date: Thu, 15 Jul 2010 15:17:23 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q2 00/19] SLUB with queueing (V2) beats SLAB netperf TCP_RR
In-Reply-To: <alpine.DEB.2.00.1007141518030.17291@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1007151515230.21299@router.home>
References: <20100709190706.938177313@quilx.com> <alpine.DEB.2.00.1007141518030.17291@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jul 2010, David Rientjes wrote:

> There are a couple differences between how you're using it compared to how
> I showed the initial regression between slab and slub, however: you're
> using localhost for your netserver which isn't representative of a real
> networking round-robin workload and you're using a smaller system with
> eight cores.  We never measured a _significant_ performance problem with
> slub compared to slab with four or eight cores, the problem only emerges
> on larger systems.

Larger systems would more NUMA support than is present in the current
patches.

> When running this patchset on two (client and server running
> netperf-2.4.5) four 2.2GHz quad-core AMD processors with 64GB of memory,
> here's the results:

What is their NUMA topology? I dont have anything beyond two nodes here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
