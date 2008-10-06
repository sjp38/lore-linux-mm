Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m96FfpO8001649
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 11:41:51 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m96FfpiH241660
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 11:41:51 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m96Fff72007195
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 11:41:41 -0400
Message-ID: <48EA31D5.70609@linux.vnet.ibm.com>
Date: Mon, 06 Oct 2008 10:42:13 -0500
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] properly reserve in bootmem the lmb reserved regions
 that cross numa nodes
References: <48E23D6C.4030406@linux.vnet.ibm.com> <1222789675.13978.14.camel@localhost.localdomain> <7E5B6DFB-F9DE-4929-8A4F-8011BF817017@kernel.crashing.org>
In-Reply-To: <7E5B6DFB-F9DE-4929-8A4F-8011BF817017@kernel.crashing.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kumar Gala <galak@kernel.crashing.org>
Cc: Adam Litke <agl@us.ibm.com>, linuxppc-dev <linuxppc-dev@ozlabs.org>, Adam Litke <agl@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Kumar Gala wrote:
> Out of interest how to do you guys represent NUMA regions of memory in
> the device tree?
>
> - k
Looking at the source code in numa.c I see at the start of
do_init_bootmem() that parse_numa_properties() is called.  It appears to
be looking at memory nodes and getting the node id from it.  It gets an
associativity property for the memory node and indexes that array with a
'min_common_depth' value to get the node id.

This node id is then used to setup the active ranges in the
early_node_map[].

Is this what you are asking about?  There are others I am sure who know
more about it then I though.

Jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
