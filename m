From: David Howells <dhowells@redhat.com>
In-Reply-To: <20070404040231.A110CDDEB8@ozlabs.org> 
References: <20070404040231.A110CDDEB8@ozlabs.org> 
Subject: Re: [PATCH 11/14] get_unmapped_area handles MAP_FIXED on ramfs (nommu) 
Date: Wed, 04 Apr 2007 11:16:58 +0100
Message-ID: <23091.1175681818@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> -	if (!(flags & MAP_SHARED))
> +	/* Deal with MAP_FIXED differently ? Forbid it ? Need help from some nommu
> +	 * folks there... --BenH.
> +	 */
> +	if ((flags & MAP_FIXED) || !(flags & MAP_SHARED))

MAP_FIXED on NOMMU?  Surely you jest...

See the first if-statement in validate_mmap_request().

If anything, you should be adding BUG_ON(flags & MAP_FIXED).

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
