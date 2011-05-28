Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A7E326B0012
	for <linux-mm@kvack.org>; Sat, 28 May 2011 10:51:48 -0400 (EDT)
Date: Sat, 28 May 2011 16:39:31 +0200
From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 10/10] mm: Create memory regions at boot-up
Message-ID: <20110528143931.GB3603@game.jcrosoft.org>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <1306499498-14263-11-git-send-email-ankita@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306499498-14263-11-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ankita Garg <ankita@in.ibm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

On 18:01 Fri 27 May     , Ankita Garg wrote:
> Memory regions are created at boot up time, from the information obtained
> from the firmware. This patchset was developed on ARM platform, on which at
> present u-boot bootloader does not export information about memory units that
> can be independently power managed. For the purpose of demonstration, 2 hard
> coded memory regions are created, of 256MB each on the Panda board with 512MB
> RAM.
> 
> Signed-off-by: Ankita Garg <ankita@in.ibm.com>
> ---
>  include/linux/mmzone.h |    8 +++-----
>  mm/page_alloc.c        |   29 +++++++++++++++++++++++++++++
>  2 files changed, 32 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index bc3e3fd..5dbe1e1 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -627,14 +627,12 @@ typedef struct mem_region_list_data {
>   */
>  struct bootmem_data;
>  typedef struct pglist_data {
> -/*	The linkage to node_zones is now removed. The new hierarchy introduced
> - *	is pg_data_t -> mem_region -> zones
> - * 	struct zone node_zones[MAX_NR_ZONES];
> - */
>  	struct zonelist node_zonelists[MAX_ZONELISTS];
>  	int nr_zones;
>  #ifdef CONFIG_FLAT_NODE_MEM_MAP	/* means !SPARSEMEM */
> -	struct page *node_mem_map;
> +	strs pg_data_t -> mem_region -> zones
> + *      struct zone node_zones[MAX_NR_ZONES];
> + */uct page *node_mem_map;
what is time?
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  	struct page_cgroup *node_page_cgroup;
>  #endif
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index da8b045..3d994e8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4285,6 +4285,34 @@ static inline int pageblock_default_order(unsigned int order)
>  
>  #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
>  
> +#define REGIONS_SIZE   (512 << 20) >> PAGE_SHIFT
fix a region size why?
> +
> +static void init_node_memory_regions(struct pglist_data *pgdat)
> +{
Best Regards,
J.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
