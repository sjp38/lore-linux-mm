Message-ID: <47C7B61C.9050808@cs.helsinki.fi>
Date: Fri, 29 Feb 2008 09:37:00 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 06/10] slub: Use the objsize from the kmem_cache_cpu structure
References: <20080229043401.900481416@sgi.com> <20080229043552.523817079@sgi.com>
In-Reply-To: <20080229043552.523817079@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> No need to access the kmem_cache structure. We have the same value
> in kmem_cache_cpu.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
