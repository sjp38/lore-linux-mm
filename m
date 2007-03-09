Date: Fri, 9 Mar 2007 08:40:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 0/3] SLUB: The unqueued slab allocator V4
In-Reply-To: <Pine.LNX.4.64.0703091355520.16052@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0703090839540.7250@schroedinger.engr.sgi.com>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0703081022040.1615@skynet.skynet.ie>
 <Pine.LNX.4.64.0703080836300.27191@schroedinger.engr.sgi.com>
 <20070308174004.GB12958@skynet.ie> <Pine.LNX.4.64.0703081135280.3130@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0703091355520.16052@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Mar 2007, Mel Gorman wrote:

> I'm not sure what you mean by per-order queues. The buddy allocator already
> has per-order lists.

Somehow they do not seem to work right. SLAB (and now SLUB too) can avoid 
(or defer) fragmentation by keeping its own queues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
