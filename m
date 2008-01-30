Date: Wed, 30 Jan 2008 09:46:38 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] SLUB: Fix sysfs refcounting
In-Reply-To: <Pine.LNX.4.64.0801291940310.22715@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0801300946150.10130@sbz-30.cs.Helsinki.FI>
References: <Pine.LNX.4.64.0801291940310.22715@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2008, Christoph Lameter wrote:
> Subject: [PATCH] SLUB: Fix sysfs refcounting
> 
> If CONFIG_SYSFS is set then free the kmem_cache structure when
> sysfs tells us its okay.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
