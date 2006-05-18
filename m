Message-ID: <446C8986.7010901@shadowen.org>
Date: Thu, 18 May 2006 15:49:42 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] zone allow unaligned zone boundaries spelling fix
References: <exportbomb.1147962048@pinky> <20060518142119.GA9521@shadowen.org>
In-Reply-To: <20060518142119.GA9521@shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, haveblue@us.ibm.com, bob.picco@hp.com, mingo@elte.hu, mbligh@mbligh.org, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> zone allow unaligned zone boundaries spelling fix
> 
> When the spelling of boundary was sorted out the config options
> got missed.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> ---
>  include/linux/mmzone.h |    2 +-
>  mm/page_alloc.c        |    4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> diff -upN reference/include/linux/mmzone.h current/include/linux/mmzone.h
> --- reference/include/linux/mmzone.h
> +++ current/include/linux/mmzone.h
> @@ -393,7 +393,7 @@ static inline int is_dma(struct zone *zo
>  
>  static inline unsigned long zone_boundary_align_pfn(unsigned long pfn)
>  {
> -#ifdef CONFIG_UNALIGNED_ZONE_BOUNDRIES
> +#ifdef CONFIG_UNALIGNED_ZONE_BOUNDARIES
>  	return pfn;
>  #else
>  	return pfn & ~((1 << MAX_ORDER) - 1);
> diff -upN reference/mm/page_alloc.c current/mm/page_alloc.c
> --- reference/mm/page_alloc.c
> +++ current/mm/page_alloc.c
> @@ -315,7 +315,7 @@ static inline int page_is_buddy(struct p
>  	if (!pfn_valid(page_to_pfn(buddy)))
>  		return 0;
>  #endif
> -#ifdef CONFIG_UNALIGNED_ZONE_BOUNDRIES
> +#ifdef CONFIG_UNALIGNED_ZONE_BOUNDARIES
>  	if (page_zone_id(page) != page_zone_id(buddy))
>  		return 0;
>  #endif
> @@ -2232,7 +2232,7 @@ static void __meminit free_area_init_cor
>  		if (zone_boundary_align_pfn(zone_start_pfn) !=
>  					zone_start_pfn && j != 0 && size != 0)
>  			printk(KERN_CRIT "node %d zone %s missaligned "
> -				"start pfn, enable UNALIGNED_ZONE_BOUNDRIES\n",
> +				"start pfn, enable UNALIGNED_ZONE_BOUNDARIES\n",
>  							nid, zone_names[j]);
>  
>  		realsize = size = zones_size[j];

Ignore this patch.  Somehow the wrong version has escaped here.  Clearly
wrong.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
