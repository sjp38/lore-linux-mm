Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 334546B01F0
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 04:32:26 -0400 (EDT)
Message-ID: <4BCA7922.4070900@kernel.org>
Date: Sun, 18 Apr 2010 12:14:42 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 5/8] numa: ia64: support numa_mem_id() for memoryless
 nodes
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain> <20100415173024.8801.36840.sendpatchset@localhost.localdomain>
In-Reply-To: <20100415173024.8801.36840.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andi@domain.invalid, Kleen@domain.invalid, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hello,

On 04/16/2010 02:30 AM, Lee Schermerhorn wrote:
> Against:  2.6.34-rc3-mmotm-100405-1609
> 
> IA64: Support memoryless nodes
> 
> Enable 'HAVE_MEMORYLESS_NODES' by default when NUMA configured
                                                     ^is
> on ia64.  Initialize percpu 'numa_mem' variable when starting
> secondary cpus.  Generic initialization will handle the boot
> cpu.
> 
> Nothing uses 'numa_mem_id()' yet.  Subsequent patch with modify
                                                      will
> slab to use this.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
