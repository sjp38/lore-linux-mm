Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 056426B0071
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 10:13:00 -0400 (EDT)
Date: Thu, 14 Jun 2012 16:12:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugeltb: Mark hugelb_max_hstate __read_mostly
Message-ID: <20120614141257.GQ27397@tiehlicka.suse.cz>
References: <1339682178-29059-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339682178-29059-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org

On Thu 14-06-12 19:26:18, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  include/linux/hugetlb.h |    2 +-
>  mm/hugetlb.c            |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 9650bb1..0f0877e 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -23,7 +23,7 @@ struct hugepage_subpool {
>  };
>  
>  extern spinlock_t hugetlb_lock;
> -extern int hugetlb_max_hstate;
> +extern int hugetlb_max_hstate __read_mostly;

It should be used only for definition

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
