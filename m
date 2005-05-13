Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4DDkV81031608
	for <linux-mm@kvack.org>; Fri, 13 May 2005 09:46:31 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4DDkVuc122026
	for <linux-mm@kvack.org>; Fri, 13 May 2005 09:46:31 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4DDkVxW018992
	for <linux-mm@kvack.org>; Fri, 13 May 2005 09:46:31 -0400
Subject: Re: NUMA aware slab allocator V2
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0505130411300.4500@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
	 <20050512000444.641f44a9.akpm@osdl.org>
	 <Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com>
	 <20050513000648.7d341710.akpm@osdl.org>
	 <Pine.LNX.4.58.0505130411300.4500@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 13 May 2005 06:46:17 -0700
Message-Id: <1115991978.7129.3.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, shai@scalex86.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 2005-05-13 at 04:21 -0700, Christoph Lameter wrote:
> The definition for the number of NUMA nodes is dependent on
> CONFIG_FLATMEM instead of CONFIG_NUMA in mm.
> CONFIG_FLATMEM is not set on ppc64 because CONFIG_DISCONTIG is set! And
> consequently nodes exist in a non NUMA config.
> 
> s/CONFIG_NUMA/CONFIG_FLATMEM/ ??

FLATMEM effectively means that you have a contiguous, single mem_map[];
it isn't directly related to NUMA.

Could you point me to the code that you're looking at?  We shouldn't
have numbers of NUMA nodes is dependent on CONFIG_FLATMEM, at least
directly.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
