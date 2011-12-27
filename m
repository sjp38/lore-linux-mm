Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 54CE26B004F
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 09:08:12 -0500 (EST)
Date: Tue, 27 Dec 2011 15:08:09 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/6] memcg: remove unused variable
Message-ID: <20111227140809.GM5344@tiehlicka.suse.cz>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
 <1324695619-5537-3-git-send-email-kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1324695619-5537-3-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

On Sat 24-12-11 05:00:16, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill@shutemov.name>
> 
> mm/memcontrol.c: In function a??mc_handle_file_ptea??:
> mm/memcontrol.c:5206:16: warning: variable a??inodea?? set but not used [-Wunused-but-set-variable]
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

Looks good.
Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!
> ---
>  mm/memcontrol.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4bac3a2..627c19e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5203,7 +5203,6 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
>  			unsigned long addr, pte_t ptent, swp_entry_t *entry)
>  {
>  	struct page *page = NULL;
> -	struct inode *inode;
>  	struct address_space *mapping;
>  	pgoff_t pgoff;
>  
> @@ -5212,7 +5211,6 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
>  	if (!move_file())
>  		return NULL;
>  
> -	inode = vma->vm_file->f_path.dentry->d_inode;
>  	mapping = vma->vm_file->f_mapping;
>  	if (pte_none(ptent))
>  		pgoff = linear_page_index(vma, addr);
> -- 
> 1.7.7.3
> 

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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
