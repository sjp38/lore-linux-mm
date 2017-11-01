Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C4EE66B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 19:20:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b85so3388019pfj.22
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 16:20:12 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o7si688024pls.588.2017.11.01.16.20.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 16:20:11 -0700 (PDT)
Subject: Re: [PATCH 3/6] hugetlb: expose hugetlbfs_inode_info in header
References: <20171031184052.25253-1-marcandre.lureau@redhat.com>
 <20171031184052.25253-4-marcandre.lureau@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <30bfff65-4cb9-a6b6-ab31-73d767a4b8ae@oracle.com>
Date: Wed, 1 Nov 2017 16:20:06 -0700
MIME-Version: 1.0
In-Reply-To: <20171031184052.25253-4-marcandre.lureau@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, hughd@google.com, nyc@holomorphy.com

On 10/31/2017 11:40 AM, Marc-AndrA(C) Lureau wrote:
> The following patch is going to access hugetlbfs_inode_info field from
> mm/shmem.c.

The code looks fine.  However, I would prefer something different for the
commit message.  Perhaps something like:

hugetlbfs inode information will need to be accessed by code in mm/shmem.c
for file sealing operations.  Move inode information definition from .c
file to header for needed access.

-- 
Mike Kravetz

> 
> Signed-off-by: Marc-AndrA(C) Lureau <marcandre.lureau@redhat.com>
> ---
>  fs/hugetlbfs/inode.c    | 10 ----------
>  include/linux/hugetlb.h | 10 ++++++++++
>  2 files changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 59073e9f01a4..ea7b10357ac4 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -55,16 +55,6 @@ struct hugetlbfs_config {
>  	umode_t			mode;
>  };
>  
> -struct hugetlbfs_inode_info {
> -	struct shared_policy policy;
> -	struct inode vfs_inode;
> -};
> -
> -static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
> -{
> -	return container_of(inode, struct hugetlbfs_inode_info, vfs_inode);
> -}
> -
>  int sysctl_hugetlb_shm_group;
>  
>  enum {
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 8bbbd37ab105..f78daf54897d 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -278,6 +278,16 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
>  	return sb->s_fs_info;
>  }
>  
> +struct hugetlbfs_inode_info {
> +	struct shared_policy policy;
> +	struct inode vfs_inode;
> +};
> +
> +static inline struct hugetlbfs_inode_info *HUGETLBFS_I(struct inode *inode)
> +{
> +	return container_of(inode, struct hugetlbfs_inode_info, vfs_inode);
> +}
> +
>  extern const struct file_operations hugetlbfs_file_operations;
>  extern const struct vm_operations_struct hugetlb_vm_ops;
>  struct file *hugetlb_file_setup(const char *name, size_t size, vm_flags_t acct,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
