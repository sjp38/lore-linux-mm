Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C775C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 07:10:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49D6821019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 07:10:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49D6821019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDAA86B0003; Wed,  8 May 2019 03:10:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8A3F6B0005; Wed,  8 May 2019 03:10:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B51C36B0007; Wed,  8 May 2019 03:10:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1486B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 03:10:52 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id g80so1057952otg.12
        for <linux-mm@kvack.org>; Wed, 08 May 2019 00:10:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=0Ncq8cjjI7Q7fLshVftWbvJPKEJGfCmWwL6iDwfzqpE=;
        b=hpx03AYAKWQIK6QA5+Zi6+ehJ32jIIwx1C7c2K19rF27WPg1aFij0DWbRfkgTXYQQM
         BjxMoFBocLp6fFMbRrJoDgyelf+lRDN/pvJVGvSR1UCyOmObZYp91NuGOFTDphVGJa+m
         vnbGWc73ExV9tWDpLw56j8TrwU+c1tZ1+M31e/MDk/7cmupgE1PkO+cLBAatLMw2is2g
         5UdmzqCL6tbTR4EPZzsV0AkceRzgn+ZtNERpO9+SPPhIO1E5MXlChuSjFyVJXT1/kTpI
         bYo0Q9sXGOyW8MPtUwjGqkssCZW60lThzs4B0SBIw7XusNWnQavNCyaOQIzpTWyodDfO
         NHYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
X-Gm-Message-State: APjAAAUX0JQFLdcLw6BtrnJ7ksr4aGeSQrchSmc5XOz3fTSq9Ctk8DFz
	E6OaRlEd4v2+moJjrfrt4TKzE6B5NNgBeNU8VaK7k01uYnXAmigLEdxIgsAWmu9PNJ4RAsXZqYa
	JLy68jGXpQX32vijWFaFpfKXNr5qpYu1wpEvCWmLZTVU9htR8nsUofXrrrl0h5qqg2w==
X-Received: by 2002:aca:5803:: with SMTP id m3mr1230670oib.4.1557299452153;
        Wed, 08 May 2019 00:10:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxC46XK0LWH4hAyKTHiICAbscQYvHE7JeGxNXZZVdZoyq8RisOb3j8EWbyHeQL48Wc4ZVxm
X-Received: by 2002:aca:5803:: with SMTP id m3mr1230643oib.4.1557299451282;
        Wed, 08 May 2019 00:10:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557299451; cv=none;
        d=google.com; s=arc-20160816;
        b=VhD4ZohWb1AXzxwdRI3yjVud9gg0Qi27XjsRMuCUf0yb/Yy+CdFhaweWNY2uX2kQRr
         9K/VVy7SyWpCibxStjGkBL5HqErpcthY2qX+chV6lbeenJaBe1VUMy6QDUxIoIpNPlcX
         Uw5JZ8Hg32i5rg7Z9a9Q2YATTJp3pNC6y+ejZ5gaEfMj5gSORuxKs5sNNlujns0ZwU9l
         vqGFfNrTdkmsEHTP/VyYoAN9XdBMDfvN23rjTrR8DqnvzdOISi7EpIWMmHCGvWfvCEya
         RNOHnK/epNNWuYVK726ZrMV1l94VsEvNKqc7qxGlY4O+vM1EltCbuuzaoIBJE9GlNfKM
         oY2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=0Ncq8cjjI7Q7fLshVftWbvJPKEJGfCmWwL6iDwfzqpE=;
        b=YF5vN1ZWQBFM/eYa9qcndOXOxE8cALBmMwTqP7ftsu0cKTImi1G8XiIFOIifjgHrtF
         CsxWsxpUqTgr7xLnfrjIM0JSI/IrNPFoypylZBFWH4NIe4x2KwvLngQETTkweFne+Z6G
         OearjUoP49Sica4hNk8I2Wio86/NcsdUebH9I7pdTNxmwzVPi0nUl3EGcZ4wOSvdaKvP
         HSHvfdj6aI4N9qmHrx+yaVS5h0XLIW6qq09sC9LE/dn4z4Dlw897510tks6Q4a+SUS/1
         87T1WgqJFuwkIUEzjK5Ip+8hxGr05YKbc5x6K/bufla41EjVHSAVfu0kxybvGrNs5eF+
         aXsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTP id o206si2556712oib.61.2019.05.08.00.10.50
        for <linux-mm@kvack.org>;
        Wed, 08 May 2019 00:10:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 410D641BD71046C7F0A4;
	Wed,  8 May 2019 15:10:18 +0800 (CST)
Received: from [127.0.0.1] (10.177.219.49) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.439.0; Wed, 8 May 2019
 15:10:08 +0800
Subject: Re: [PATCH] hugetlbfs: always use address space in inode for resv_map
 pointer
To: Mike Kravetz <mike.kravetz@oracle.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
CC: Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi
	<n-horiguchi@ah.jp.nec.com>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>,
	<stable@vger.kernel.org>, <yuyufen@huawei.com>
References: <20190416065058.GB11561@dhcp22.suse.cz>
 <20190419204435.16984-1-mike.kravetz@oracle.com>
From: yuyufen <yuyufen@huawei.com>
Message-ID: <fafe9985-7db1-b65c-523d-875ab4b3b3b8@huawei.com>
Date: Wed, 8 May 2019 15:10:06 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.2.1
MIME-Version: 1.0
In-Reply-To: <20190419204435.16984-1-mike.kravetz@oracle.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Originating-IP: [10.177.219.49]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/4/20 4:44, Mike Kravetz wrote:
> Continuing discussion about commit 58b6e5e8f1ad ("hugetlbfs: fix memory
> leak for resv_map") brought up the issue that inode->i_mapping may not
> point to the address space embedded within the inode at inode eviction
> time.  The hugetlbfs truncate routine handles this by explicitly using
> inode->i_data.  However, code cleaning up the resv_map will still use
> the address space pointed to by inode->i_mapping.  Luckily, private_data
> is NULL for address spaces in all such cases today but, there is no
> guarantee this will continue.
>
> Change all hugetlbfs code getting a resv_map pointer to explicitly get
> it from the address space embedded within the inode.  In addition, add
> more comments in the code to indicate why this is being done.
>
> Reported-by: Yufen Yu <yuyufen@huawei.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>   fs/hugetlbfs/inode.c | 11 +++++++++--
>   mm/hugetlb.c         | 19 ++++++++++++++++++-
>   2 files changed, 27 insertions(+), 3 deletions(-)
>
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 9285dd4f4b1c..cbc649cd1722 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -499,8 +499,15 @@ static void hugetlbfs_evict_inode(struct inode *inode)
>   	struct resv_map *resv_map;
>   
>   	remove_inode_hugepages(inode, 0, LLONG_MAX);
> -	resv_map = (struct resv_map *)inode->i_mapping->private_data;
> -	/* root inode doesn't have the resv_map, so we should check it */
> +
> +	/*
> +	 * Get the resv_map from the address space embedded in the inode.
> +	 * This is the address space which points to any resv_map allocated
> +	 * at inode creation time.  If this is a device special inode,
> +	 * i_mapping may not point to the original address space.
> +	 */
> +	resv_map = (struct resv_map *)(&inode->i_data)->private_data;
> +	/* Only regular and link inodes have associated reserve maps */
>   	if (resv_map)
>   		resv_map_release(&resv_map->refs);
>   	clear_inode(inode);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6cdc7b2d9100..b30e97b0ef37 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -740,7 +740,15 @@ void resv_map_release(struct kref *ref)
>   
>   static inline struct resv_map *inode_resv_map(struct inode *inode)
>   {
> -	return inode->i_mapping->private_data;
> +	/*
> +	 * At inode evict time, i_mapping may not point to the original
> +	 * address space within the inode.  This original address space
> +	 * contains the pointer to the resv_map.  So, always use the
> +	 * address space embedded within the inode.
> +	 * The VERY common case is inode->mapping == &inode->i_data but,
> +	 * this may not be true for device special inodes.
> +	 */
> +	return (struct resv_map *)(&inode->i_data)->private_data;
>   }
>   
>   static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
> @@ -4477,6 +4485,11 @@ int hugetlb_reserve_pages(struct inode *inode,
>   	 * called to make the mapping read-write. Assume !vma is a shm mapping
>   	 */
>   	if (!vma || vma->vm_flags & VM_MAYSHARE) {
> +		/*
> +		 * resv_map can not be NULL as hugetlb_reserve_pages is only
> +		 * called for inodes for which resv_maps were created (see
> +		 * hugetlbfs_get_inode).
> +		 */
>   		resv_map = inode_resv_map(inode);
>   
>   		chg = region_chg(resv_map, from, to);
> @@ -4568,6 +4581,10 @@ long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
>   	struct hugepage_subpool *spool = subpool_inode(inode);
>   	long gbl_reserve;
>   
> +	/*
> +	 * Since this routine can be called in the evict inode path for all
> +	 * hugetlbfs inodes, resv_map could be NULL.
> +	 */
>   	if (resv_map) {
>   		chg = region_del(resv_map, start, end);
>   		/*

Dose this patch have been applied?

I think it is better to add fixes label, like:
Fixes: 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")

Since the commit 58b6e5e8f1a has been merged to stable, this patch also 
be needed.
https://www.spinics.net/lists/stable/msg298740.html





