Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4KJ3w0c552780
	for <linux-mm@kvack.org>; Fri, 20 May 2005 15:03:58 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4KJ3web227492
	for <linux-mm@kvack.org>; Fri, 20 May 2005 13:03:58 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4KJ3w19011285
	for <linux-mm@kvack.org>; Fri, 20 May 2005 13:03:58 -0600
Message-ID: <428E3497.3080406@us.ibm.com>
Date: Fri, 20 May 2005 12:03:51 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: NUMA aware slab allocator V3
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>  <Pine.LNX.4.62.0505161046430.1653@schroedinger.engr.sgi.com>  <714210000.1116266915@flay> <200505161410.43382.jbarnes@virtuousgeek.org>  <740100000.1116278461@flay>  <Pine.LNX.4.62.0505161713130.21512@graphe.net> <1116289613.26955.14.camel@localhost> <428A800D.8050902@us.ibm.com> <Pine.LNX.4.62.0505171648370.17681@graphe.net> <428B7B16.10204@us.ibm.com> <Pine.LNX.4.62.0505181046320.20978@schroedinger.engr.sgi.com> <428BB05B.6090704@us.ibm.com> <Pine.LNX.4.62.0505181439080.10598@graphe.net> <Pine.LNX.4.62.0505182105310.17811@graphe.net>
In-Reply-To: <Pine.LNX.4.62.0505182105310.17811@graphe.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph, I'm getting the following errors building rc4-mm2 w/ GCC 2.95.4:

mm/slab.c:281: field `entry' has incomplete typemm/slab.c: In function
'cache_alloc_refill':
mm/slab.c:2497: warning: control reaches end of non-void function
mm/slab.c: In function `kmem_cache_alloc':
mm/slab.c:2567: warning: `objp' might be used uninitialized in this function
mm/slab.c: In function `kmem_cache_alloc_node':
mm/slab.c:2567: warning: `objp' might be used uninitialized in this function
mm/slab.c: In function `__kmalloc':
mm/slab.c:2567: warning: `objp' might be used uninitialized in this function
make[1]: *** [mm/slab.o] Error 1
make[1]: *** Waiting for unfinished jobs....

-Matt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
