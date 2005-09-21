Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8LJZIct002915
	for <linux-mm@kvack.org>; Wed, 21 Sep 2005 15:35:18 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8LJZI5x097676
	for <linux-mm@kvack.org>; Wed, 21 Sep 2005 15:35:18 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8LJZIqU008417
	for <linux-mm@kvack.org>; Wed, 21 Sep 2005 15:35:18 -0400
Subject: Re: [PATCH 1/4] hugetlbfs: move free_inodes accounting
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050921092156.GA22544@lst.de>
References: <20050921092156.GA22544@lst.de>
Content-Type: text/plain
Date: Wed, 21 Sep 2005 12:34:57 -0700
Message-Id: <1127331297.10664.6.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@osdl.org>, viro@ftp.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-09-21 at 11:21 +0200, Christoph Hellwig wrote:
> +static inline int hugetlbfs_inc_free_inodes(struct hugetlbfs_sb_info
> *sbinfo)
> +{
> +       if (sbinfo->free_inodes >= 0) {
> +               spin_lock(&sbinfo->stat_lock);
> +               if (unlikely(!sbinfo->free_inodes)) {
> +                       spin_unlock(&sbinfo->stat_lock);
> +                       return 0;
> +               }
> +               sbinfo->free_inodes--;
> +               spin_unlock(&sbinfo->stat_lock);
> +       }

Does that really need the unlikely()?  Doesn't seem horribly performance
critical.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
