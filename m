Date: Fri, 11 Aug 2006 11:51:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
In-Reply-To: <20060811114243.49fa4390.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0608111150550.18495@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
 <20060810124137.6da0fdef.akpm@osdl.org> <Pine.LNX.4.64.0608102010150.12657@schroedinger.engr.sgi.com>
 <20060811110821.51096659.akpm@osdl.org> <Pine.LNX.4.64.0608111112000.18296@schroedinger.engr.sgi.com>
 <20060811114243.49fa4390.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, pj@sgi.com, jes@sgi.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Aug 2006, Andrew Morton wrote:

> How about we do
> 
> /*
>  * We do this to avoid lots of ifdefs and their consequential conditional
>  * compilation
>  */
> #ifdef CONFIG_NUMA
> #define NUMA_BUILD 1
> #else
> #define NUMA_BUILD 0
> #endif

Put this in kernel.h?

Sounds good but this sets a new precedent on how to avoid #ifdefs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
