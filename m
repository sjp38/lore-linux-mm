Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8EC3C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:32:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B35B32053B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:32:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B35B32053B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FA466B0288; Wed,  8 May 2019 07:32:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D17D6B028A; Wed,  8 May 2019 07:32:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 472FD6B028B; Wed,  8 May 2019 07:32:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0C66B0288
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:32:20 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id w3so10891832otg.11
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:32:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding;
        bh=qYrqwcfbxdpy5titRiqhjVHM0ZEFPFxXB9jJbZiBS2g=;
        b=K1f6MHt42t3R/kkPvtBmT6r1iID39jKvYpq9d19eYmy745kNp6E06qLZrXE9Wru35A
         hiXeLWryqyg0h/HU9J6aY/AwMhssRbq+vcV3uz83qgGfJyepHTWBzRWMIJx2a09lqd1w
         cT0YF0oEuVWJi4gUHvVxP+WFajWlWzTdyy8cIQ7V7YZa9pta0HF/q1ZzqS8OgR86RYWU
         NZDhCsDuSOovLj0TTOfk/LeuUGYAKMOjNG3jnkFnqbvrnZaAyVoRjPolFQ9GUb73vO4d
         0CFGwmjpeiAlk85N3n+t1XeaA+bVJVR5g0wrzWRUDbOs896AtrPLGbdAngJ0kxPoQAux
         mRFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
X-Gm-Message-State: APjAAAXOM0yAVUC7wCbDzLYI5oVKUMa7J1wmSdFPTtTJ91j4MuSyrpWE
	IgxGR30V0K+70sbV8yV4StaK6fVMTmRPjBaK1tbWiLUanq4ZiPmJ4asgtQ9N6iurKQ9kEf/yZHy
	Sb5KNhJmse668HZDl00LszQSUklwK5s3XzpBwuZKpSratNPOPzfF09/ARqhGQ1LpY7w==
X-Received: by 2002:aca:f592:: with SMTP id t140mr1880327oih.76.1557315139781;
        Wed, 08 May 2019 04:32:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/91vKPGV6T8ljB7Kh+p0CLznmNxIaTy6PxwlvH7tfbJAPOFNPhqwNo2IhYJTgtDFfZI4A
X-Received: by 2002:aca:f592:: with SMTP id t140mr1880290oih.76.1557315138964;
        Wed, 08 May 2019 04:32:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557315138; cv=none;
        d=google.com; s=arc-20160816;
        b=KxXpZ8rx0u2F1HOLk5JKC2cHw5hbCmhRGQ14XIj6hZyvSqW0/NKNLH9s49Utb+cv5e
         abAewz0Shp47hCO0w3WcqrfyccxLQLPylvAEfdomPsBkgVnWxZJmy5k2HaUIbHg3DRyT
         7q/d5Av6dl/cdsdDhG29UoeyVKKuRoSc9rz899AqG0+FPPnDk4RjRmhLVqBdF2fHKSbD
         WU4mcV/hXcbn7zLCVNy/D2/0o/cKWUbJnUMVJ0O9Z7sFJyxxNJffJVoyeULFRQ1nr5Or
         tEObu5DduJEeRchAdpOw8PKaxcFLlyI71+fey4N+e/olsyhtTYzyVl+oJfUm3pKpHG8Q
         OlEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject;
        bh=qYrqwcfbxdpy5titRiqhjVHM0ZEFPFxXB9jJbZiBS2g=;
        b=vt6JP0nFzc2WLqjqCrAnO8fsQtWAqQVQBgIL7mfbNDa76LCzLsXB6WJqGkvQsYbjve
         KoT8BuZEHryNcSgXnbNkUwrqe01h5i41ADtZcufzUdJH44mrmExpmLdG+cUUs8sZ5N/S
         KEALKPdSpQnfdEsPIstSkk4r1zQwwh6o97SBvQh0Gf1lDfMOAfRKwDIiQV7Oz7bWjmjL
         yFofZKr9bPhgr6d5UEgkHULDKS/HwFfisyaOjzTtBv9hEB6+tADMkK9Vjmpx1WbnHoWO
         ttw3MbtlF25pVR/S//QZpfUMX8v7XINPfzvjuCicCnfhLZMuiHf7zzFbUbqHmY3xKD2g
         s/0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id c17si6959855otn.154.2019.05.08.04.32.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 04:32:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 5982ABEEDEE367A789E0;
	Wed,  8 May 2019 19:32:13 +0800 (CST)
Received: from [127.0.0.1] (10.184.225.177) by DGGEMS403-HUB.china.huawei.com
 (10.3.19.203) with Microsoft SMTP Server id 14.3.439.0; Wed, 8 May 2019
 19:32:06 +0800
Subject: Re: [PATCH v2] mm/hugetlb: Don't put_page in lock of hugetlb_lock
To: Mike Kravetz <mike.kravetz@oracle.com>, <mhocko@suse.com>,
	<shenkai8@huawei.com>, <linfeilong@huawei.com>, Andrew Morton
	<akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<wangwang2@huawei.com>, "Zhoukang (A)" <zhoukang7@huawei.com>, Mingfangsen
	<mingfangsen@huawei.com>, <agl@us.ibm.com>, <nacc@us.ibm.co>
References: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
 <b8ade452-2d6b-0372-32c2-703644032b47@huawei.com>
 <9405fcd5-a5a7-db4a-d613-acf2872f6e62@oracle.com>
From: Zhiqiang Liu <liuzhiqiang26@huawei.com>
Message-ID: <21971d7f-aec7-bc38-7f9b-08c1bf96be9e@huawei.com>
Date: Wed, 8 May 2019 19:31:43 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <9405fcd5-a5a7-db4a-d613-acf2872f6e62@oracle.com>
Content-Type: text/plain; charset="gbk"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.225.177]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On 5/6/19 7:06 AM, Zhiqiang Liu wrote:
>> From: Kai Shen <shenkai8@huawei.com>
>>
>> spinlock recursion happened when do LTP test:
>> #!/bin/bash
>> ./runltp -p -f hugetlb &
>> ./runltp -p -f hugetlb &
>> ./runltp -p -f hugetlb &
>> ./runltp -p -f hugetlb &
>> ./runltp -p -f hugetlb &
>>
>> The dtor returned by get_compound_page_dtor in __put_compound_page
>> may be the function of free_huge_page which will lock the hugetlb_lock,
>> so don't put_page in lock of hugetlb_lock.
>>
>>  BUG: spinlock recursion on CPU#0, hugemmap05/1079
>>   lock: hugetlb_lock+0x0/0x18, .magic: dead4ead, .owner: hugemmap05/1079, .owner_cpu: 0
>>  Call trace:
>>   dump_backtrace+0x0/0x198
>>   show_stack+0x24/0x30
>>   dump_stack+0xa4/0xcc
>>   spin_dump+0x84/0xa8
>>   do_raw_spin_lock+0xd0/0x108
>>   _raw_spin_lock+0x20/0x30
>>   free_huge_page+0x9c/0x260
>>   __put_compound_page+0x44/0x50
>>   __put_page+0x2c/0x60
>>   alloc_surplus_huge_page.constprop.19+0xf0/0x140
>>   hugetlb_acct_memory+0x104/0x378
>>   hugetlb_reserve_pages+0xe0/0x250
>>   hugetlbfs_file_mmap+0xc0/0x140
>>   mmap_region+0x3e8/0x5b0
>>   do_mmap+0x280/0x460
>>   vm_mmap_pgoff+0xf4/0x128
>>   ksys_mmap_pgoff+0xb4/0x258
>>   __arm64_sys_mmap+0x34/0x48
>>   el0_svc_common+0x78/0x130
>>   el0_svc_handler+0x38/0x78
>>   el0_svc+0x8/0xc
>>
>> Fixes: 9980d744a0 ("mm, hugetlb: get rid of surplus page accounting tricks")
>> Signed-off-by: Kai Shen <shenkai8@huawei.com>
>> Signed-off-by: Feilong Lin <linfeilong@huawei.com>
>> Reported-by: Wang Wang <wangwang2@huawei.com>
>> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Good catch.  Sorry, for the late reply.
> 
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> 

Thank your for the reply.
Friendly ping ...


