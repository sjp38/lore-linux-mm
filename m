Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 8209D6B0069
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 22:01:07 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so24393047pbb.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 19:01:06 -0700 (PDT)
Date: Mon, 9 Jul 2012 19:01:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/hugetlb: fix error code in hugetlbfs_alloc_inode
In-Reply-To: <20120710011516.GA2457@kernel>
Message-ID: <alpine.DEB.2.00.1207091859280.25143@chino.kir.corp.google.com>
References: <1341882184-4549-1-git-send-email-liwp.linux@gmail.com> <20120710010910.GA7362@shangw> <20120710011516.GA2457@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, William Irwin <wli@holomorphy.com>, linux-kernel@vger.kernel.org

On Tue, 10 Jul 2012, Wanpeng Li wrote:

> >>diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> >>index c4b85d0..79a0f33 100644
> >>--- a/fs/hugetlbfs/inode.c
> >>+++ b/fs/hugetlbfs/inode.c
> >>@@ -696,7 +696,7 @@ static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
> >> 	p = kmem_cache_alloc(hugetlbfs_inode_cachep, GFP_KERNEL);
> >> 	if (unlikely(!p)) {
> >> 		hugetlbfs_inc_free_inodes(sbinfo);
> >>-		return NULL;
> >>+		return -ENOMEM;
> >
> >The function is expecting "struct inode *", man.
> >
> >static struct inode *hugetlbfs_alloc_inode(struct super_block *sb)
> >
> Hmm, replace it by ERR_PTR(-ENOMEM). 
> 

Please listen to the feedback you're getting before you reply.

This function is called by alloc_inode().  It tests whether the return 
value is NULL or not, it doesn't check for PTR_ERR().  It's correct the 
way it's written and you would have broken it.

In the future, please demonstrate how you've tested your patches before 
proposing them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
