Date: Thu, 22 Aug 2002 20:22:39 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Lse-tech] [patch] SImple Topology API v0.3 (1/2)
Message-ID: <20020822202239.A30036@infradead.org>
References: <3D6537D3.3080905@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D6537D3.3080905@us.ibm.com>; from colpatch@us.ibm.com on Thu, Aug 22, 2002 at 12:13:23PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Bligh <mjbligh@us.ibm.com>, Andrea Arcangeli <andrea@suse.de>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2002 at 12:13:23PM -0700, Matthew Dobson wrote:
> --- linux-2.5.27-vanilla/include/linux/mmzone.h	Sat Jul 20 12:11:05 2002
> +++ linux-2.5.27-api/include/linux/mmzone.h	Wed Jul 24 17:33:41 2002
> @@ -220,15 +20,15 @@
>  #define NODE_MEM_MAP(nid)	mem_map
>  #define MAX_NR_NODES		1
>  
> -#else /* !CONFIG_DISCONTIGMEM */
> -
> -#include <asm/mmzone.h>
> +#else /* CONFIG_DISCONTIGMEM */
>  
>  /* page->zone is currently 8 bits ... */
>  #define MAX_NR_NODES		(255 / MAX_NR_ZONES)
>  
>  #endif /* !CONFIG_DISCONTIGMEM */
>  
> +#include <asm/mmzone.h>
> +

What is the exact purpose of this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
