Date: Sun, 15 May 2005 22:00:17 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: NUMA aware slab allocator V3
Message-Id: <20050515220017.6271c55e.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.62.0505140908480.17517@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>
	<20050512000444.641f44a9.akpm@osdl.org>
	<Pine.LNX.4.58.0505121252390.32276@schroedinger.engr.sgi.com>
	<20050513000648.7d341710.akpm@osdl.org>
	<Pine.LNX.4.58.0505130411300.4500@schroedinger.engr.sgi.com>
	<20050513043311.7961e694.akpm@osdl.org>
	<Pine.LNX.4.62.0505131823210.12315@schroedinger.engr.sgi.com>
	<20050514004204.2302dc52.akpm@osdl.org>
	<Pine.LNX.4.62.0505140908480.17517@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, shai@scalex86.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> Here is Dave's patch again:
> 
>  =====================================================================
>  I think I found the problem.  Could you try the attached patch?
> 
>  As I said before FLATMEM is really referring to things like the
>  mem_map[] or max_mapnr.
> 
>  CONFIG_NEED_MULTIPLE_NODES is what gets turned on for DISCONTIG or for
>  NUMA.  We'll slowly be removing all of the DISCONTIG cases, so
>  eventually it will merge back to be one with NUMA.
> 
>  -- Dave
> 
>  --- clean/include/linux/numa.h.orig     2005-05-13 06:44:56.000000000 
>  -0700
>  +++ clean/include/linux/numa.h  2005-05-13 06:52:05.000000000 -0700
>  @@ -3,7 +3,7 @@
> 
>   #include <linux/config.h>
> 
>  -#ifndef CONFIG_FLATMEM
>  +#ifdef CONFIG_NEED_MULTIPLE_NODES
>   #include <asm/numnodes.h>
>   #endif

Nope.

mm/slab.c:117:2: #error "Broken Configuration: CONFIG_NUMA not set but MAX_NUMNODES !=1 !!"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
