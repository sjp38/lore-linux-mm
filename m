Message-ID: <47C7BB9E.5020406@cs.helsinki.fi>
Date: Fri, 29 Feb 2008 10:00:30 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 03/10] slub: Remove objsize check in kmem_cache_flags()
References: <20080229043401.900481416@sgi.com> <20080229043551.868567605@sgi.com>
In-Reply-To: <20080229043551.868567605@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> There is no page->offset anymore and also no associated limit on the number
> of objects. The page->offset field was removed for 2.6.24. So the check
> in kmem_cache_flags() is now also obsolete (should have been dropped
> earlier, somehow a hunk vanished).
> 
> Signed-by: Christoph Lameter <clameter@sgi.com>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
