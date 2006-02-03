Date: Fri, 3 Feb 2006 08:47:42 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] pearing off zone from physical memory layout [0/10]
In-Reply-To: <43E307DB.3000903@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.62.0602030842310.386@schroedinger.engr.sgi.com>
References: <43E307DB.3000903@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Feb 2006, KAMEZAWA Hiroyuki wrote:

> By this, zone's meaning will be changed from "a range of memory to be used
> in a same manner" to "a group of memory to be used in a same manner".

For us on IA64 a zone describes the memory of a node in a NUMA system. 
This is due to our IA64 not having memory issues like restricted DMA 
areas or not directly addressable memory.

That memory is to be used in the same manner. Yes. So in principle this 
would also work for us. I'd like to have an option though to get rid of 
all the extra zones if one has a clean memory architecture. We still carry 
the DMA and HIGHMEM stuff around without purpose.

Would this also mean that one can dynamically add/remove memory to a zone 
if the memory has to be treated the same way?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
