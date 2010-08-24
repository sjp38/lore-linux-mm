Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 55DE16B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 11:36:15 -0400 (EDT)
Date: Tue, 24 Aug 2010 10:37:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch] slob: fix gfp flags for order-0 page allocations
In-Reply-To: <1282663241.10679.958.camel@calx>
Message-ID: <alpine.DEB.2.00.1008241036250.344@router.home>
References: <alpine.DEB.2.00.1008221615350.29062@chino.kir.corp.google.com>  <1282623994.10679.921.camel@calx>  <alpine.DEB.2.00.1008232134480.25742@chino.kir.corp.google.com> <1282663241.10679.958.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010, Matt Mackall wrote:

> kmalloc-32        1113344 1113344     32  128    1 : tunables    0    0
> 0 : slabdata   8698   8698      0
>
> That's /proc/slabinfo on my laptop with SLUB. It looks like my last
> reboot popped me back to 2.6.33 so it may also be old news, but I
> couldn't spot any reports with Google.

Boot with "slub_debug" as a kernel parameter

and then do a

cat /sys/kernel/slab/kmalloc-32/alloc_calls

to find the caller allocating the objets.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
