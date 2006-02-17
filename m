Date: Fri, 17 Feb 2006 15:10:04 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback list initialization
In-Reply-To: <Pine.LNX.4.64.0602161749330.27091@schroedinger.engr.sgi.com>
References: <200602170223.34031.ak@suse.de> <Pine.LNX.4.64.0602161749330.27091@schroedinger.engr.sgi.com>
Message-Id: <20060217145409.4064.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andi Kleen <ak@suse.de>, torvalds@osdl.org, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Empty nodes are not initialization, but the node number is still 
> > allocated. And then it would early except or even triple fault here  
> > because it would try to set  up a fallback list for a NULL pgdat. Oops.
> 
> Isnt this an issue with the arch code? Simply do not allocate an empty 
> node. Is the mapping from linux Node id -> Hardware node id fixed on 
> x86_64? ia64 has a lookup table.

Do you mention about pxm_to_nid_map[]? 
I picked it out to driver/acpi/numa.c. (see: current -mm)
It is not arch specific. pxm is acpi's spec, and node id is generic
linux kernel code. :-P


> These are empty nodes without processor? Or a processor without a node?
> In that case the processor will have to be assigned a default node.

??? 
Ia64 added the feature of memory less node long time ago.

This is in arch/ia64/mm/discontig.c

 406 /**
 407  * memory_less_nodes - allocate and initialize CPU only nodes pernode
 408  *      information.
 410 static void __init memory_less_nodes(void)
 411 {
 409  */
                       :
                       :


Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
