Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id E278F6B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 11:39:04 -0400 (EDT)
Date: Fri, 24 Aug 2012 17:39:02 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 2/5] mm/memblock: rename
	get_allocated_memblock_reserved_regions_info()
Message-ID: <20120824153902.GA22555@merkur.ravnborg.org>
References: <1345818820-12102-1-git-send-email-liwanp@linux.vnet.ibm.com> <1345818820-12102-2-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345818820-12102-2-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>

On Fri, Aug 24, 2012 at 10:33:37PM +0800, Wanpeng Li wrote:
> From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> 
> Rename get_allocated_memblock_reserved_regions_info() to
> memblock_reserved_regions_info() so that the function name
> looks more short and has prefix "memblock".
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  include/linux/memblock.h |    2 +-
>  mm/memblock.c            |    2 +-
>  mm/nobootmem.c           |    2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 569d67d..ab7b887 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -50,7 +50,7 @@ phys_addr_t memblock_find_in_range_node(phys_addr_t start, phys_addr_t end,
>  				phys_addr_t size, phys_addr_t align, int nid);
>  phys_addr_t memblock_find_in_range(phys_addr_t start, phys_addr_t end,
>  				   phys_addr_t size, phys_addr_t align);
> -phys_addr_t get_allocated_memblock_reserved_regions_info(phys_addr_t *addr);
> +phys_addr_t memblock_reserved_regions_info(phys_addr_t *addr);
When you anyway change the prototype a description of what this function
is supposed to be used for would be good.
Many memblock function lacks this :-(

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
