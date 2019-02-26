Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02116C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 02:22:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F64D21841
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 02:22:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F64D21841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2B1D8E0003; Mon, 25 Feb 2019 21:22:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB5E18E0002; Mon, 25 Feb 2019 21:22:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7D568E0003; Mon, 25 Feb 2019 21:22:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 934208E0002
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 21:22:52 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id r13so5924531otn.10
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 18:22:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=ECARpSwXnhvgAlRX5fisvhJrlkHQlIGmYnCbRxddYzs=;
        b=Py5C6MjUWthE5TaUVltluMR8riZC7raaeMY7W2FRNCkJkCbaMxALuOlkXXEJPSqL/n
         omwaUd1EciXUXpjkPRsDll69Q5dE1T9feBFFUG9872SAqzDMVV7upVM6iyhA9UcqmAfx
         jTWHIUkT+QZNaP9UOuP4Zn3T6PVFkwC4MBIV0nK5f8fzYrL8WNVQPDH7S3NY6tr8uARp
         RkWl55w/pCCQP63p+dkH5cwyfzb2EVYDlpjqulb9gG3Q6zLomTNK6Bcv86/gqq/m1w31
         pvmyA0DeBGFZJZX3MCy47qTxO4v8Gr2oIwCQlDZWIvYihjrw+xTulsdu8kSPD20qtsm/
         3ZEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
X-Gm-Message-State: AHQUAua/TJy6e8aIAnvjo6kC+vOQdmEMzYHmn2C2LNJrDN4KIQzrI7mq
	DkW1VPseIfjdB3AdbiU+GMS0vxDPSSu0Fxo7frkv+DA9e2sHwHHDILfj2OEi7XhiJYVuR+Zz6DK
	eAYwebXS2x0mZ0DEC6ab7j0/gYLHwwSX/6WHA2QQnQxg0e6HIDA0M80HjnmWbGgNtqg==
X-Received: by 2002:aca:a9cb:: with SMTP id s194mr918118oie.177.1551147772234;
        Mon, 25 Feb 2019 18:22:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYhXH7vgu3qfd98UECpwm2wkS3Vi4JV3DKtHfK9PS+xXOVfnBq7aXDkZfGuZoqxqcLDqNQm
X-Received: by 2002:aca:a9cb:: with SMTP id s194mr918075oie.177.1551147771198;
        Mon, 25 Feb 2019 18:22:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551147771; cv=none;
        d=google.com; s=arc-20160816;
        b=jY7ALEMfe7CYjzBZ3UBiLYuHPzKp6sTrNcKdk1RYwmwufWk9CtDrfdoIzsQ9tDYl7Z
         sKekbAW9Fyf6/j1Ajx+HFVljiD5pHfdHYfIcEPnG1hGl5wXTIwMae9woYFV4qMXvn/PV
         l3uPQRz5JJNAps7vBsOa3pHR1r+lIVdgihclahm4WDEHw/QwOgrRIeHZqTwfA9eQhThg
         lpcIzRwsv72bgLMtaiCRt3CNaDqeTgbDvfJ2iRv2FybxzlqSD0KJ+BIOmxJ2YmwWpIaB
         ICCw/FiYm3qZqDMVMdHkhgwN3jY0QEO1AqE9LJZJanKL9tEobIJ5FXa3jdTwZFp+8U9T
         n3VQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=ECARpSwXnhvgAlRX5fisvhJrlkHQlIGmYnCbRxddYzs=;
        b=IbV9D0/TqJI4lfKwv2QpUz2eZGYZvLh5GjpD6gP5P5/sc0IpxcEodmXeigqfJ8kUAp
         hmzZ9XsIqZmdGJkrBcqQqpjuhJKsy7/u8NRhMB4A4YqpRBOiqeoXJnuYRTlF7IGaOuhs
         mtPkhddEMzH29EwGZuqexc8wI7EevTMWNccTYMKCx4KAF9hFI82T7MBhFu4HZPYofcMp
         90OacSehC8oRK+rrl9Oln/+s1SHbY7Jdfg1oPxlTgRVVALHD0+3C0po6F+i/kziaQppP
         SR3dCJGTc6Y/DzMwrxNCRs4VdaMKzGb2dkIx6JFtkUyXFtOg8t0vOrkgKqQLulet8U8G
         c01A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id z13si4518126otq.277.2019.02.25.18.22.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 18:22:51 -0800 (PST)
Received-SPF: pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 87861A41F452FCD66313;
	Tue, 26 Feb 2019 10:22:39 +0800 (CST)
Received: from [127.0.0.1] (10.184.39.28) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.408.0; Tue, 26 Feb 2019
 10:22:36 +0800
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
To: David Rientjes <rientjes@google.com>, Mike Kravetz
	<mike.kravetz@oracle.com>
References: <1550885529-125561-1-git-send-email-jingxiangfeng@huawei.com>
 <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
 <alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com>
 <8c167be7-06fa-a8c0-8ee7-0bfad41eaba2@oracle.com>
 <13400ee2-3d3b-e5d6-2d78-a770820417de@oracle.com>
 <alpine.DEB.2.21.1902251116180.167839@chino.kir.corp.google.com>
CC: <mhocko@kernel.org>, <akpm@linux-foundation.org>, <hughd@google.com>,
	<linux-mm@kvack.org>, <n-horiguchi@ah.jp.nec.com>, <aarcange@redhat.com>,
	<kirill.shutemov@linux.intel.com>, <linux-kernel@vger.kernel.org>
From: Jing Xiangfeng <jingxiangfeng@huawei.com>
Message-ID: <5C74A2DA.1030304@huawei.com>
Date: Tue, 26 Feb 2019 10:22:18 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101
 Thunderbird/38.1.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1902251116180.167839@chino.kir.corp.google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.39.28]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/2/26 3:17, David Rientjes wrote:
> On Mon, 25 Feb 2019, Mike Kravetz wrote:
> 
>> Ok, what about just moving the calculation/check inside the lock as in the
>> untested patch below?
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>  mm/hugetlb.c | 34 ++++++++++++++++++++++++++--------
>>  1 file changed, 26 insertions(+), 8 deletions(-)
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 1c5219193b9e..5afa77dc7bc8 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -2274,7 +2274,7 @@ static int adjust_pool_surplus(struct hstate *h,
>> nodemask_t *nodes_allowed,
>>  }
>>
>>  #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
>> -static int set_max_huge_pages(struct hstate *h, unsigned long count,
>> +static int set_max_huge_pages(struct hstate *h, unsigned long count, int nid,
>>  						nodemask_t *nodes_allowed)
>>  {
>>  	unsigned long min_count, ret;
>> @@ -2289,6 +2289,23 @@ static int set_max_huge_pages(struct hstate *h, unsigned
>> long count,
>>  		goto decrease_pool;
>>  	}
>>
>> +	spin_lock(&hugetlb_lock);
>> +
>> +	/*
>> +	 * Check for a node specific request.  Adjust global count, but
>> +	 * restrict alloc/free to the specified node.
>> +	 */
>> +	if (nid != NUMA_NO_NODE) {
>> +		unsigned long old_count = count;
>> +		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
>> +		/*
>> +		 * If user specified count causes overflow, set to
>> +		 * largest possible value.
>> +		 */
>> +		if (count < old_count)
>> +			count = ULONG_MAX;
>> +	}
>> +
>>  	/*
>>  	 * Increase the pool size
>>  	 * First take pages out of surplus state.  Then make up the
>> @@ -2300,7 +2317,6 @@ static int set_max_huge_pages(struct hstate *h, unsigned
>> long count,
>>  	 * pool might be one hugepage larger than it needs to be, but
>>  	 * within all the constraints specified by the sysctls.
>>  	 */
>> -	spin_lock(&hugetlb_lock);
>>  	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
>>  		if (!adjust_pool_surplus(h, nodes_allowed, -1))
>>  			break;
>> @@ -2421,16 +2437,18 @@ static ssize_t __nr_hugepages_store_common(bool
>> obey_mempolicy,
>>  			nodes_allowed = &node_states[N_MEMORY];
>>  		}
>>  	} else if (nodes_allowed) {
>> +		/* Node specific request */
>> +		init_nodemask_of_node(nodes_allowed, nid);
>> +	} else {
>>  		/*
>> -		 * per node hstate attribute: adjust count to global,
>> -		 * but restrict alloc/free to the specified node.
>> +		 * Node specific request, but we could not allocate
>> +		 * node mask.  Pass in ALL nodes, and clear nid.
>>  		 */
>> -		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
>> -		init_nodemask_of_node(nodes_allowed, nid);
>> -	} else
>> +		nid = NUMA_NO_NODE;
>>  		nodes_allowed = &node_states[N_MEMORY];
>> +	}
>>
>> -	err = set_max_huge_pages(h, count, nodes_allowed);
>> +	err = set_max_huge_pages(h, count, nid, nodes_allowed);
>>  	if (err)
>>  		goto out;
>>
> 
> Looks good; Jing, could you test that this fixes your case?

Yes, I have tested this patch, it can also fix my case.
> 
> .
> 


