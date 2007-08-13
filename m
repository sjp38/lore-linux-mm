Date: Mon, 13 Aug 2007 13:46:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] [438/2many] MAINTAINERS - SLAB ALLOCATOR
In-Reply-To: <46bffbc9.9Jtz7kOTKn1mqlkq%joe@perches.com>
Message-ID: <Pine.LNX.4.64.0708131345130.27728@schroedinger.engr.sgi.com>
References: <46bffbc9.9Jtz7kOTKn1mqlkq%joe@perches.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: joe@perches.com
Cc: torvalds@linux-foundation.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sun, 12 Aug 2007, joe@perches.com wrote:

> Add file pattern to MAINTAINER entry
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index b2dd6f5..a3c6123 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4168,6 +4168,8 @@ P:	Pekka Enberg
>  M:	penberg@cs.helsinki.fi
>  L:	linux-mm@kvack.org
>  S:	Maintained
> +F:	include/linux/slab*

Use include/linux/sl?b*.h 

> +F:	mm/slab.c

Use mm/sl?b.c ?

Otherwise this does not include slub f.e.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
