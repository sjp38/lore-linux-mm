Date: Thu, 26 Apr 2007 08:48:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] change global zonelist order on NUMA v2
In-Reply-To: <20070426191043.df96c114.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0704260846590.1382@schroedinger.engr.sgi.com>
References: <20070426183417.058f6f9e.kamezawa.hiroyu@jp.fujitsu.com>
 <200704261147.44413.ak@suse.de> <20070426191043.df96c114.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Apr 2007, KAMEZAWA Hiroyuki wrote:

> (1)Use new zonelist ordering always and move init_task's tied cpu to a
>   cpu on the best node. 
>   Child processes will start in good nodes even if Node 0 has small memory.

How about renumbering the nodes? Node 0 is the one with no DMA memory and 
node 1 may be the one with the DMA? That would take care of things even 
without core modifications. We can start on node 0 (which hardware 1) and 
consume the required memory for boot there not impacting the node with the 
DMA memory.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
