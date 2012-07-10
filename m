Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id DF0436B0072
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 21:15:24 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so24329813pbb.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 18:15:24 -0700 (PDT)
Date: Tue, 10 Jul 2012 09:15:16 +0800
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: Re: [PATCH] mm/hugetlb: fix error code in hugetlbfs_alloc_inode
Message-ID: <20120710011516.GA2457@kernel>
Reply-To: Wanpeng Li <liwp.linux@gmail.com>
References: <1341882184-4549-1-git-send-email-liwp.linux@gmail.com>
 <20120710010910.GA7362@shangw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120710010910.GA7362@shangw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, William Irwin <wli@holomorphy.com>, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

On Tue, Jul 10, 2012 at 09:09:10AM +0800, Gavin Shan wrote:
>On Tue, Jul 10, 2012 at 09:03:04AM +0800, Wanpeng Li wrote:
>>From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>>
>>When kmem_cache_alloc fails alloc slab object from
>>hugetlbfs_inode_cachep, return -ENOMEM in usual. But
>>hugetlbfs_alloc_inode implementation has inconsitency
>>with it and returns NULL. Fix it to return -ENOMEM.
>>
>>Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
>>---
>> fs/hugetlbfs/inode.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>>diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>>index c4b85d0..79a0f33 100644
>>--- a/fs/hugetlbfs/inode.c
>>+++ b/fs/hugetlbfs/inode.c
>>@@ -696,7 +696,7 @@ static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
>> 	p = kmem_cache_alloc(hugetlbfs_inode_cachep, GFP_KERNEL);
>> 	if (unlikely(!p)) {
>> 		hugetlbfs_inc_free_inodes(sbinfo);
>>-		return NULL;
>>+		return -ENOMEM;
>
>The function is expecting "struct inode *", man.
>
>static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
>
Hmm, replace it by ERR_PTR(-ENOMEM). 

Regards,
Wanpeng Li

>Thanks,
>Gavin
>
>> 	}
>> 	return &p->vfs_inode;
>> }
>>-- 
>>1.7.5.4
>>
>>--
>>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>the body to majordomo@kvack.org.  For more info on Linux MM,
>>see: http://www.linux-mm.org/ .
>>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
