Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id C7BE96B0363
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 11:39:07 -0400 (EDT)
Date: Mon, 25 Jun 2012 17:39:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 5/5] mm/sparse: return 0 if root mem_section exists
Message-ID: <20120625153905.GC19810@tiehlicka.suse.cz>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340466776-4976-5-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340466776-4976-5-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Sat 23-06-12 23:52:56, Gavin Shan wrote:
> Function sparse_index_init() is used to setup memory section descriptors
> dynamically. zero should be returned while mem_section[root] already has
> been allocated.

Doesn't this break sparse_add_one_section which expects EEXIST?

> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>  mm/sparse.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index a8b99d3..e845a48 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -109,8 +109,12 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>  	struct mem_section *section;
>  	int ret = 0;
>  
> +	/*
> +	 * If the corresponding mem_section descriptor
> +	 * has been created, we needn't bother
> +	 */
>  	if (mem_section[root])
> -		return -EEXIST;
> +		return ret;
>  
>  	section = sparse_index_alloc(nid);
>  	if (!section)
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
