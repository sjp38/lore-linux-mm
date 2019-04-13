Return-Path: <SRS0=SBXn=SP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7183C10F11
	for <linux-mm@archiver.kernel.org>; Sat, 13 Apr 2019 11:57:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DA412075B
	for <linux-mm@archiver.kernel.org>; Sat, 13 Apr 2019 11:57:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DA412075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7ED26B0006; Sat, 13 Apr 2019 07:57:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E04C06B0008; Sat, 13 Apr 2019 07:57:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA4606B000A; Sat, 13 Apr 2019 07:57:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 955836B0006
	for <linux-mm@kvack.org>; Sat, 13 Apr 2019 07:57:54 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id d38so6208743otb.22
        for <linux-mm@kvack.org>; Sat, 13 Apr 2019 04:57:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=6iwuzJsHC6V7Ldwv8vci8hEkwKXoRhXmxPiCYkgFUJg=;
        b=YfXloFxUdDFjsyHAH6qCnZpo+erdWJdGpUS6f3rJJB8Pl1idb1SRxMWobX8B87QdqO
         7UkCHKPTlhbZNHdiAottf15HUThO2vfXo+/yni+eNogYvoFpBOPCEmJ9gDiJ1LJcU3ZB
         0gz7UwRvfn4opNyohEJGwcPv6t5cOqvg+MFarUDjRV85kNsZYqDFvnh3nTsfuiZrRR0J
         82T1/OFdulMie48sJ/3EJDnXSe/r32ukIdS6r7C930suXJ3wQFcEU8Hme9OQN19mqk/t
         c56m9Z8L3sXFxgV5YgkAF1DA6zIwBRLntPdtcEmzjCmTNlekItKRzQ7PPrKHQHwOCMca
         CK3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
X-Gm-Message-State: APjAAAVtmL8IEhBK4OXcIDV5EWdZt4awaIwQE4FOrZ1N5auMlwIeIqVR
	b8DTuOODl9b7qlxurZ6XcdJkHmDai4fKd0ZcLQGDXByA6S9INNV+3E6khE81nOaJnA7RRSyfb6d
	ZUnbI60DQeG0upgkXdMmF+sSJbHZmzhgRDG0//WdRmA4b6V5v1+qt74aXx9oVf7kTOQ==
X-Received: by 2002:aca:5750:: with SMTP id l77mr13091895oib.54.1555156674190;
        Sat, 13 Apr 2019 04:57:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRPNCIqv9v3MHHJKTJc/gTgFwnqS3C63nGtRhU7+gSHHx2OwaeZ3HzRYoALu04mtix2n9J
X-Received: by 2002:aca:5750:: with SMTP id l77mr13091878oib.54.1555156673356;
        Sat, 13 Apr 2019 04:57:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555156673; cv=none;
        d=google.com; s=arc-20160816;
        b=Up0doMy8Bh+stlqZ04PyT07BOq2eTKhojHQ5ahsTfNlNm0BkobqgMEAM++GR++QOOu
         zI+ziCDD/ETrcy15vYV3v0LGR5q5T1QyshovGuRJYgk07qzfwuvuZRLnpLEJNtvMN/Ex
         LT9STlNJcYHJEs1i9NP2MvTmV68ehNh+tl84AL83xRHDzcxLKFV8jNNqZjR1y7t7esXT
         3ighvFDkZb2RnXDgjpUHUWp95WBhbDXdA5j+7bjChjjKMZEG6QI06+7ds8aUYnu+mXzH
         VlCb0DpjqQUoa1UbT7cqEJjrMcjmfK93J3wf7lFzCVcl6QiZo7al+yYdZUkX0skXLy11
         IaEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=6iwuzJsHC6V7Ldwv8vci8hEkwKXoRhXmxPiCYkgFUJg=;
        b=po+H5+ChXi7ujU2yeGiMDeL6eYIXuieA6o5xIXum7120aJOE1UbsbY5sQ6bWyMMNj3
         XdxA6cYUCVC4p3Mwln64oDOkWIxGaYDMbMNgkq/PqwEcJo+GcC2oQ4/rgr1pjJmt4zOH
         sy4x5qjH4HZm3it0skTxrDVA6Qxkp9BGf8ToymKYm1a5HK2XgiBm2+2foBCGF5kiDkuz
         dPWWoyTKhyFWOUJFcBA/+sc9eWGdJGTELGpfKP20aMkvfGzDB/7yVIXGRop8nzCkVve/
         Ui40Aw60C3N4O6nwh/0d9Za7/J2Bo10HJlFhMJdF+Ep3bfSG1FIUN6cOUh55PrNJctSd
         NpJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id a8si17635555oti.5.2019.04.13.04.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Apr 2019 04:57:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuyufen@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuyufen@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 6A97378886EA0BE67FAB;
	Sat, 13 Apr 2019 19:57:47 +0800 (CST)
Received: from [127.0.0.1] (10.177.219.49) by DGGEMS408-HUB.china.huawei.com
 (10.3.19.208) with Microsoft SMTP Server id 14.3.408.0; Sat, 13 Apr 2019
 19:57:45 +0800
Subject: Re: [PATCH] hugetlbfs: move resv_map to hugetlbfs_inode_info
To: Mike Kravetz <mike.kravetz@oracle.com>, <linux-mm@kvack.org>
CC: <mhocko@kernel.org>, <n-horiguchi@ah.jp.nec.com>,
	<kirill.shutemov@linux.intel.com>
References: <20190412040240.29861-1-yuyufen@huawei.com>
 <83a4e275-405f-f1d8-2245-d597bef2ec69@oracle.com>
From: yuyufen <yuyufen@huawei.com>
Message-ID: <856cf079-d7ef-afbf-7c78-b70103b419e7@huawei.com>
Date: Sat, 13 Apr 2019 19:57:44 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.2.1
MIME-Version: 1.0
In-Reply-To: <83a4e275-405f-f1d8-2245-d597bef2ec69@oracle.com>
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



On 2019/4/13 7:40, Mike Kravetz wrote:
> This specific part of the patch made me think,
>
>> @@ -497,12 +497,15 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>>   static void hugetlbfs_evict_inode(struct inode *inode)
>>   {
>>   	struct resv_map *resv_map;
>> +	struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
>>   
>>   	remove_inode_hugepages(inode, 0, LLONG_MAX);
>> -	resv_map = (struct resv_map *)inode->i_mapping->private_data;
>> +	resv_map = info->resv_map;
>>   	/* root inode doesn't have the resv_map, so we should check it */
>> -	if (resv_map)
>> +	if (resv_map) {
>>   		resv_map_release(&resv_map->refs);
>> +		info->resv_map = NULL;
>> +	}
>>   	clear_inode(inode);
>>   }
> If inode->i_mapping may not be associated with the hugetlbfs inode, then
> remove_inode_hugepages() will also have problems.  It will want to operate
> on the address space associated with the inode.  So, there are more issues
> than just the resv_map.  When I looked at the first few lines of
> remove_inode_hugepages(), I was surprised to see:
>
> 	struct address_space *mapping = &inode->i_data;

Good catch!

> So remove_inode_hugepages is explicitly using the original address space
> that is embedded in the inode.  As a result, it is not impacted by changes
> to inode->i_mapping.  Using git history I was unable to determine why
> remove_inode_hugepages is the only place in hugetlbfs code doing this.
>
> With this in mind, a simple change like the following will fix the original
> leak issue as well as the potential issues mentioned in this patch.
>
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 53ea3cef526e..9f0719bad46f 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -511,6 +511,11 @@ static void hugetlbfs_evict_inode(struct inode *inode)
>   {
>   	struct resv_map *resv_map;
>   
> +	/*
> +	 * Make sure we are operating on original hugetlbfs address space.
> +	 */
> +	inode->i_mapping = &inode->i_data;
> +
>   	remove_inode_hugepages(inode, 0, LLONG_MAX);
>   	resv_map = (struct resv_map *)inode->i_mapping->private_data;
>   	/* root inode doesn't have the resv_map, so we should check it */
>
>
> I don't know why hugetlbfs code would ever want to operate on any address
> space but the one embedded within the inode.  However, my uderstanding of
> the vfs layer is somewhat limited.  I'm wondering if the hugetlbfs code
> (helper routines mostly) should perhaps use &inode->i_data instead of
> inode->i_mapping.  Does it ever make sense for hugetlbfs code to operate
> on inode->i_mapping if inode->i_mapping != &inode->i_data ?

I also feel very confused.

Yufen
thanks.

