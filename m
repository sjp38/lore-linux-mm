Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1346B0266
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 11:25:09 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s19-v6so95595iog.0
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 08:25:09 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t13-v6si1914261itt.105.2018.06.20.08.25.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 08:25:08 -0700 (PDT)
Subject: Re: [PATCH] hugetlbfs: Fix an error code in init_hugetlbfs_fs()
References: <20180620110921.2s4krw4zjbnfniq5@kili.mountain>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <869220cd-d3f0-2be9-b333-46bbfea9af48@oracle.com>
Date: Wed, 20 Jun 2018 08:25:04 -0700
MIME-Version: 1.0
In-Reply-To: <20180620110921.2s4krw4zjbnfniq5@kili.mountain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>, David Howells <dhowells@redhat.com>
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On 06/20/2018 04:09 AM, Dan Carpenter wrote:
> We accidentally deleted the error code assignment.
> 
> Fixes: 9b82d88c136c ("hugetlbfs: Convert to fs_context")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Thanks for catching this,
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 9a5c9fcf54f5..91fadca3c8e6 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -1482,8 +1482,10 @@ static int __init init_hugetlbfs_fs(void)
>  	i = 0;
>  	for_each_hstate(h) {
>  		mnt = mount_one_hugetlbfs(h);
> -		if (IS_ERR(mnt) && i == 0)
> +		if (IS_ERR(mnt) && i == 0) {
> +			error = PTR_ERR(mnt);
>  			goto out;
> +		}
>  		hugetlbfs_vfsmount[i] = mnt;
>  		i++;
>  	}
> 
