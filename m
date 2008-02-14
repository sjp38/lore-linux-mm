Subject: Re: [patch 2/5] slub: Fallback to kmalloc_large for failing higher order allocs
In-Reply-To: <20080214040313.616551392@sgi.com>
Message-ID: <pCfVfDKg.1202972648.0235790.penberg@cs.helsinki.fi>
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Date: Thu, 14 Feb 2008 09:04:08 +0200 (EET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On 2/14/2008, "Christoph Lameter" <clameter@sgi.com> wrote:
> We can use that handoff to avoid failing if a higher order kmalloc slab
> allocation cannot be satisfied by the page allocator. If we reach the
> out of memory path then simply try a kmalloc_large(). kfree() can
> already handle the case of an object that was allocated via the page
> allocator and so this will work just fine (apart from object
> accounting...).

Sorry, I didn't follow the discussion close enough. Why are we doing
this? Is it fixing some real bug I am not aware of?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
