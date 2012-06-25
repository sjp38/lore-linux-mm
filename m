Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 313676B0337
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 08:14:51 -0400 (EDT)
Date: Mon, 25 Jun 2012 14:14:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugetlb/cgroup: Remove unnecessary NULL checks
Message-ID: <20120625121448.GL19805@tiehlicka.suse.cz>
References: <1340556313-12789-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340556313-12789-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org

On Sun 24-06-12 22:15:13, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> cgroup_subsys_state can never be NULL, so don't check
> for that in hugetlb_cgroup_from_css. Also current task will
> always be part of some cgroup. So hugetlb_cgrop_from_task
> cannot return NULL.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/hugetlb_cgroup.c |    7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index db40669..b834e8d 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -36,9 +36,7 @@ static struct hugetlb_cgroup *root_h_cgroup __read_mostly;
>  static inline
>  struct hugetlb_cgroup *hugetlb_cgroup_from_css(struct cgroup_subsys_state *s)
>  {
> -	if (s)
> -		return container_of(s, struct hugetlb_cgroup, css);
> -	return NULL;
> +	return container_of(s, struct hugetlb_cgroup, css);
>  }
>  
>  static inline
> @@ -202,9 +200,6 @@ int hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,
>  again:
>  	rcu_read_lock();
>  	h_cg = hugetlb_cgroup_from_task(current);
> -	if (!h_cg)
> -		h_cg = root_h_cgroup;
> -
>  	if (!css_tryget(&h_cg->css)) {
>  		rcu_read_unlock();
>  		goto again;
> -- 
> 1.7.10
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
