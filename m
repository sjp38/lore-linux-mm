Date: Tue, 29 Nov 2005 09:53:55 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [patch 3/3] mm: NUMA slab -- minor optimizations
In-Reply-To: <20051129085456.GC3573@localhost.localdomain>
Message-ID: <Pine.LNX.4.62.0511290953310.14722@schroedinger.engr.sgi.com>
References: <20051129085049.GA3573@localhost.localdomain>
 <20051129085456.GC3573@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, manfred@colorfullife.com, Alok Kataria <alokk@calsoftinc.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Nov 2005, Ravikiran G Thirumalai wrote:

> Patch adds some minor optimizations:
> 1. Keeps on chip interrupts enabled for a bit longer while draining cpu
> caches
> 2. Calls numa_node_id once in cache_reap
> 
> Signed-off-by: Alok N Kataria <alokk@calsoftinc.com>
> Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
> Signed-off-by: Shai Fultheim <shai@scalex86.org>

Ack-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
