Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id BB7FE6B0069
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 21:09:19 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 9 Jul 2012 21:09:18 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 7E3136E804D
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 21:09:16 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6A19GG4312806
	for <linux-mm@kvack.org>; Mon, 9 Jul 2012 21:09:16 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6A6e80U000799
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 02:40:09 -0400
Date: Tue, 10 Jul 2012 09:09:10 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/hugetlb: fix error code in hugetlbfs_alloc_inode
Message-ID: <20120710010910.GA7362@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1341882184-4549-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341882184-4549-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, William Irwin <wli@holomorphy.com>, linux-kernel@vger.kernel.org

On Tue, Jul 10, 2012 at 09:03:04AM +0800, Wanpeng Li wrote:
>From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>
>When kmem_cache_alloc fails alloc slab object from
>hugetlbfs_inode_cachep, return -ENOMEM in usual. But
>hugetlbfs_alloc_inode implementation has inconsitency
>with it and returns NULL. Fix it to return -ENOMEM.
>
>Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
>---
> fs/hugetlbfs/inode.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>index c4b85d0..79a0f33 100644
>--- a/fs/hugetlbfs/inode.c
>+++ b/fs/hugetlbfs/inode.c
>@@ -696,7 +696,7 @@ static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
> 	p = kmem_cache_alloc(hugetlbfs_inode_cachep, GFP_KERNEL);
> 	if (unlikely(!p)) {
> 		hugetlbfs_inc_free_inodes(sbinfo);
>-		return NULL;
>+		return -ENOMEM;

The function is expecting "struct inode *", man.

static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)

Thanks,
Gavin

> 	}
> 	return &p->vfs_inode;
> }
>-- 
>1.7.5.4
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
