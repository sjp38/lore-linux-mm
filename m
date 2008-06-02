Received: by hu-out-0506.google.com with SMTP id 34so4212071hui.6
        for <linux-mm@kvack.org>; Mon, 02 Jun 2008 05:44:04 -0700 (PDT)
Subject: Re: [PATCH -mm 03/14] bootmem: add documentation to API functions
From: Chris Malley <mail@chrismalley.co.uk>
In-Reply-To: <20080530194737.756122438@saeurebad.de>
References: <20080530194220.286976884@saeurebad.de>
	 <20080530194737.756122438@saeurebad.de>
Content-Type: text/plain; charset=UTF-8
Date: Mon, 02 Jun 2008 13:18:04 +0100
Message-Id: <1212409084.25657.0.camel@helix.beotel.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-05-30 at 21:42 +0200, Johannes Weiner wrote:

> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
> ---
> 
>  mm/bootmem.c |  147 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 146 insertions(+), 1 deletion(-)
> 
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c

[snip]

>  
> +/**
> + * reserve_bootmem_node - mark a page range as reserved
> + * @addr: starting address of the range
> + * @size: size of the range in bytes

kerneldoc arguments don't match the actual function definition.

> + *
> + * Partial pages will be reserved.
> + *
> + * Only physical pages that actually reside on @pgdat are marked.
> + */
>  void __init reserve_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
>  				 unsigned long size, int flags)
>  {
> @@ -331,6 +390,16 @@ void __init reserve_bootmem_node(pg_data
>  }
>  
>  #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
> +/**
> + * reserve_bootmem - mark a page range as usable
> + * @addr: starting address of the range
> + * @size: size of the range in bytes


and here (missing @flags)

> i>>?i>>?+ *
> + * Partial pages will be reserved.
> + *
> + * All physical pages within the range are marked, no matter what
> + * node they reside on.
> + */
>  int __init reserve_bootmem(unsigned long addr, unsigned long size,
>  			    int flags)
>  {
> @@ -499,6 +568,19 @@ found:
>  	return ret;
>  }
>  

cheers
Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
