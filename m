Date: Sat, 1 Mar 2008 11:59:30 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 08/10] slub: Remove BUG_ON() from ksize and omit checks
 for !SLUB_DEBUG
In-Reply-To: <Pine.LNX.4.64.0802291133060.11084@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0803011158550.19118@sbz-30.cs.Helsinki.FI>
References: <20080229043401.900481416@sgi.com> <20080229043553.076119937@sgi.com>
 <47C7B826.4090603@cs.helsinki.fi> <Pine.LNX.4.64.0802291133060.11084@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008, Pekka Enberg wrote:
> > Why are you wrapping the SLAB_DESTORY_BY_RCU case with CONFIG_SLUB_DEBUG too?

On Fri, 29 Feb 2008, Christoph Lameter wrote:
> Mistake on my part. Corrected patch follows:
> 
> From 74d3c465f217f3103e7a6d21cb090497386de8be Mon Sep 17 00:00:00 2001
> From: Christoph Lameter <clameter@sgi.com>
> Date: Fri, 15 Feb 2008 23:45:25 -0800
> Subject: [PATCH] slub: Remove BUG_ON() from ksize and omit checks for !SLUB_DEBUG
> 
> The BUG_ONs are useless since the pointer derefs will lead to
> NULL deref errors anyways. Some of the checks are not necessary
> if no debugging is possible.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
