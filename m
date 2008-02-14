Subject: Re: [patch 1/5] slub: Determine gfpflags once and not every time a slab is allocated
In-Reply-To: <20080214040313.318658830@sgi.com>
Message-ID: <Kua3E9iW.1202973819.2315200.penberg@cs.helsinki.fi>
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Date: Thu, 14 Feb 2008 09:23:39 +0200 (EET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 2/14/2008, "Christoph Lameter" <clameter@sgi.com> wrote:
> Currently we determine the gfp flags to pass to the page allocator
> each time a slab is being allocated.
> 
> Determine the bits to be set at the time the slab is created. Store
> in a new allocflags field and add the flags in allocate_slab().

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
