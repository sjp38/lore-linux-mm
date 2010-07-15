Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A1B3F6B02A5
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 16:31:10 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o6FKV41t021582
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 13:31:04 -0700
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by kpbe17.cbf.corp.google.com with ESMTP id o6FKV2vw026059
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 13:31:03 -0700
Received: by pxi10 with SMTP id 10so678684pxi.30
        for <linux-mm@kvack.org>; Thu, 15 Jul 2010 13:31:02 -0700 (PDT)
Date: Thu, 15 Jul 2010 13:30:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q2 00/19] SLUB with queueing (V2) beats SLAB netperf TCP_RR
In-Reply-To: <alpine.DEB.2.00.1007151515230.21299@router.home>
Message-ID: <alpine.DEB.2.00.1007151329000.9903@chino.kir.corp.google.com>
References: <20100709190706.938177313@quilx.com> <alpine.DEB.2.00.1007141518030.17291@chino.kir.corp.google.com> <alpine.DEB.2.00.1007151515230.21299@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jul 2010, Christoph Lameter wrote:

> > When running this patchset on two (client and server running
> > netperf-2.4.5) four 2.2GHz quad-core AMD processors with 64GB of memory,
> > here's the results:
> 
> What is their NUMA topology? I dont have anything beyond two nodes here.
> 

These two machines happen to have four 16GB nodes with asymmetrical 
distances:

# cat /sys/devices/system/node/node*/distance
10 20 20 30
20 10 20 20
20 20 10 20
30 20 20 10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
