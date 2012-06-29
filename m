Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 3D2D86B0069
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:32:40 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6011532pbb.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 11:32:39 -0700 (PDT)
Date: Fri, 29 Jun 2012 11:32:33 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH for -3.5] memblock: free allocated
 memblock_reserved_regions later
Message-ID: <20120629183233.GC21048@google.com>
References: <CAE9FiQXqb4NVnWeJR75+gfwCkKMtBh2GDwoSijPf4JEezfqcnQ@mail.gmail.com>
 <1340994477-3122-1-git-send-email-yinghai@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340994477-3122-1-git-send-email-yinghai@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Sasha Levin <levinsasha928@gmail.com>, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hello, Yinghai.

Just one nitpick.

On Fri, Jun 29, 2012 at 11:27:57AM -0700, Yinghai Lu wrote:
>  /**
>   * memblock_double_array - double the size of the memblock regions array
>   * @type: memblock type of the regions array being doubled
> @@ -204,6 +192,7 @@ static int __init_memblock memblock_doub
>  						phys_addr_t new_area_size)
>  {
>  	struct memblock_region *new_array, *old_array;
> +	phys_addr_t old_alloc_size, new_alloc_size;
>  	phys_addr_t old_size, new_size, addr;
>  	int use_slab = slab_is_available();
>  	int *in_slab;
> @@ -217,6 +206,12 @@ static int __init_memblock memblock_doub
>  	/* Calculate new doubled size */
>  	old_size = type->max * sizeof(struct memblock_region);
>  	new_size = old_size << 1;
> +	/*
> +	 * We need to allocated new one align to PAGE_SIZE,
> +	 *  so late could free them completely.

An extra space and probably "so we can free them completely later"
fits better.

Thank you!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
