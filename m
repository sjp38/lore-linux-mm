Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC4866B0069
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 13:42:39 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id u48so202847qtc.3
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 10:42:39 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id s87si4070699qks.40.2017.09.29.10.42.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 10:42:38 -0700 (PDT)
Subject: Re: [PATCH] mm/hugetlbfs: Remove the redundant -ENIVAL return from
 hugetlbfs_setattr()
References: <20170929145444.17611-1-khandual@linux.vnet.ibm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <63e6e530-5e75-c498-3323-c91b3cd76e00@oracle.com>
Date: Fri, 29 Sep 2017 10:42:31 -0700
MIME-Version: 1.0
In-Reply-To: <20170929145444.17611-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: nyc@holomorphy.com, Andrew Morton <akpm@linux-foundation.org>

Adding akpm on Cc:

On 09/29/2017 07:54 AM, Anshuman Khandual wrote:
> There is no need to have a local return code set with -EINVAL when both the
> conditions following it return error codes appropriately. Just remove the
> redundant one.
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  fs/hugetlbfs/inode.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 59073e9..cff3939 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -668,7 +668,6 @@ static int hugetlbfs_setattr(struct dentry *dentry, struct iattr *attr)
>  		return error;
>  
>  	if (ia_valid & ATTR_SIZE) {
> -		error = -EINVAL;
>  		if (attr->ia_size & ~huge_page_mask(h))
>  			return -EINVAL;
>  		error = hugetlb_vmtruncate(inode, attr->ia_size);
> 

Thanks for noticing.
I would hope the compiler is smarter than the code and optimize this away.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
