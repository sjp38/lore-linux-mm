Date: Thu, 16 Feb 2006 17:51:54 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback
 list initialization
In-Reply-To: <200602170223.34031.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0602161749330.27091@schroedinger.engr.sgi.com>
References: <200602170223.34031.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: torvalds@osdl.org, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Feb 2006, Andi Kleen wrote:

> Empty nodes are not initialization, but the node number is still 
> allocated. And then it would early except or even triple fault here  
> because it would try to set  up a fallback list for a NULL pgdat. Oops.

Isnt this an issue with the arch code? Simply do not allocate an empty 
node. Is the mapping from linux Node id -> Hardware node id fixed on 
x86_64? ia64 has a lookup table.

These are empty nodes without processor? Or a processor without a node?
In that case the processor will have to be assigned a default node.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
