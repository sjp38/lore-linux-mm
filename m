Date: Wed, 28 Jul 2004 07:37:23 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC][PATCH 2/2] perzone slab LRUs
Message-ID: <34870000.1091025443@[10.10.2.4]>
In-Reply-To: <41078A3D.6040103@yahoo.com.au>
References: <410789EB.1060209@yahoo.com.au> <41078A3D.6040103@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Oops, forgot to CC linux-mm.
> 
> Nick Piggin wrote:
>> This patch is only intended for comments.
>> 
>> This implements (crappy?) infrastructure for per-zone slab LRUs for
>> reclaimable slabs, and moves dcache.c over to use that.
>> 
>> The global unused list is retained to reduce intrusiveness, and another
>> per-zone LRU list is added (which are still protected with the global 
>> dcache
>> lock). This is an attempt to make slab scanning more robust on highmem and
>> NUMA systems.

Do we have slab that goes in highmem anywhere? I thought not .... 64 bit
NUMA makes a lot of sense though.

M

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
