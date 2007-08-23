Date: Thu, 23 Aug 2007 13:05:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] 2.6.23-rc3-mm1 kernel BUG at mm/page_alloc.c:2876!
In-Reply-To: <46CDC11E.2010008@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0708231303050.14720@schroedinger.engr.sgi.com>
References: <46CC9A7A.2030404@linux.vnet.ibm.com>
 <20070822134800.ce5a5a69.akpm@linux-foundation.org>
 <20070822135024.dde8ef5a.akpm@linux-foundation.org> <20070823130732.GC18456@skynet.ie>
 <46CDC11E.2010008@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2007, Kamalesh Babulal wrote:

> After applying the patch, the call trace is gone but the kernel bug
> is still hit

Yes that is what we expected. We need more information to figure out why 
the kmalloc_node fails there. It should walk through all nodes to find 
memory.

I see that you have 4 cpus and 16 nodes. How are the cpus assigned to 
nodes? If a cpu would be assigned to a nonexisting node then this could be 
the result.

Could you post the full boot log?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
