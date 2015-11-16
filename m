Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 912156B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 07:39:30 -0500 (EST)
Received: by wmdw130 with SMTP id w130so109092061wmd.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:39:30 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 12si25425107wmg.120.2015.11.16.04.39.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 04:39:29 -0800 (PST)
Received: by wmuu63 with SMTP id u63so25614306wmu.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:39:29 -0800 (PST)
Date: Mon, 16 Nov 2015 13:39:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/7] ipc/shm: is_file_shm_hugepages can be boolean
Message-ID: <20151116123927.GB14116@dhcp22.suse.cz>
References: <1447656686-4851-1-git-send-email-baiyaowei@cmss.chinamobile.com>
 <1447656686-4851-2-git-send-email-baiyaowei@cmss.chinamobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447656686-4851-2-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: akpm@linux-foundation.org, bhe@redhat.com, dan.j.williams@intel.com, dave.hansen@linux.intel.com, dave@stgolabs.net, dhowells@redhat.com, dingel@linux.vnet.ibm.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, holt@sgi.com, iamjoonsoo.kim@lge.com, joe@perches.com, kuleshovmail@gmail.com, mgorman@suse.de, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, penberg@kernel.org, rientjes@google.com, sasha.levin@oracle.com, tj@kernel.org, tony.luck@intel.com, vbabka@suse.cz, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-11-15 14:51:20, Yaowei Bai wrote:
> This patch makes is_file_shm_hugepages return bool to improve
> readability due to this particular function only using either
> one or zero as its return value.

yes it makes sense here.

> No functional change.
> 
> Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/shm.h | 6 +++---
>  ipc/shm.c           | 2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/shm.h b/include/linux/shm.h
> index 6fb8016..04e8818 100644
> --- a/include/linux/shm.h
> +++ b/include/linux/shm.h
> @@ -52,7 +52,7 @@ struct sysv_shm {
>  
>  long do_shmat(int shmid, char __user *shmaddr, int shmflg, unsigned long *addr,
>  	      unsigned long shmlba);
> -int is_file_shm_hugepages(struct file *file);
> +bool is_file_shm_hugepages(struct file *file);
>  void exit_shm(struct task_struct *task);
>  #define shm_init_task(task) INIT_LIST_HEAD(&(task)->sysvshm.shm_clist)
>  #else
> @@ -66,9 +66,9 @@ static inline long do_shmat(int shmid, char __user *shmaddr,
>  {
>  	return -ENOSYS;
>  }
> -static inline int is_file_shm_hugepages(struct file *file)
> +static inline bool is_file_shm_hugepages(struct file *file)
>  {
> -	return 0;
> +	return false;
>  }
>  static inline void exit_shm(struct task_struct *task)
>  {
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 4178727..ed3027d 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -459,7 +459,7 @@ static const struct file_operations shm_file_operations_huge = {
>  	.fallocate	= shm_fallocate,
>  };
>  
> -int is_file_shm_hugepages(struct file *file)
> +bool is_file_shm_hugepages(struct file *file)
>  {
>  	return file->f_op == &shm_file_operations_huge;
>  }
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
