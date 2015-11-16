Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6E9D66B0254
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 07:40:46 -0500 (EST)
Received: by wmww144 with SMTP id w144so117208593wmw.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:40:46 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id y198si25442056wmd.101.2015.11.16.04.40.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 04:40:45 -0800 (PST)
Received: by wmuu63 with SMTP id u63so25623779wmu.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:40:45 -0800 (PST)
Date: Mon, 16 Nov 2015 13:40:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/7] mm/hugetlb: is_file_hugepages can be boolean
Message-ID: <20151116124043.GC14116@dhcp22.suse.cz>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
 <1447656686-4851-3-git-send-email-baiyaowei@cmss.chinamobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447656686-4851-3-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: akpm@linux-foundation.org, bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-11-15 14:51:21, Yaowei Bai wrote:
> This patch makes is_file_hugepages return bool to improve
> readability due to this particular function only using either
> one or zero as its return value.
> 
> This patch also removed the if condition to make is_file_hugepages
> return directly.
> 
> No functional change.
> 
> Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>

I think this could be squashed into the previous patch.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/hugetlb.h | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 685c262..204c7f5 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -265,20 +265,18 @@ struct file *hugetlb_file_setup(const char *name, size_t size, vm_flags_t acct,
>  				struct user_struct **user, int creat_flags,
>  				int page_size_log);
>  
> -static inline int is_file_hugepages(struct file *file)
> +static inline bool is_file_hugepages(struct file *file)
>  {
>  	if (file->f_op == &hugetlbfs_file_operations)
> -		return 1;
> -	if (is_file_shm_hugepages(file))
> -		return 1;
> +		return true;
>  
> -	return 0;
> +	return is_file_shm_hugepages(file);
>  }
>  
>  
>  #else /* !CONFIG_HUGETLBFS */
>  
> -#define is_file_hugepages(file)			0
> +#define is_file_hugepages(file)			false
>  static inline struct file *
>  hugetlb_file_setup(const char *name, size_t size, vm_flags_t acctflag,
>  		struct user_struct **user, int creat_flags,
> -- 
> 1.9.1
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
