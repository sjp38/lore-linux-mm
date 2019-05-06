Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E071EC04AAD
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 14:06:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB2AA2054F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 14:06:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB2AA2054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 591706B0007; Mon,  6 May 2019 10:06:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5424B6B0008; Mon,  6 May 2019 10:06:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3955D6B000A; Mon,  6 May 2019 10:06:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D2F66B0007
	for <linux-mm@kvack.org>; Mon,  6 May 2019 10:06:02 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id h186so4315855oia.13
        for <linux-mm@kvack.org>; Mon, 06 May 2019 07:06:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding;
        bh=v0ZpZthk7KC02tnE2qOshb5LHR8NT8ZwOlhQdJj64P4=;
        b=BVcUsj76i2HPi8EwelGbZBjh12n4JxYnVqb5KEQPvepGxqO5zZGW16ajd200fFGDPr
         Z+h3y8cmP73ZnzAOsnFpCRvuIav1/NCyaw256rEphnAtDnBsZmjJ8nz2e8d0io1BPIlz
         C5SgjucMWPJLJeapejSbEmIRjjHoqeqya4jrzpNH4Vz7NrYccFFSlDTmZ2oaML9fJFLc
         MYX1nGIyWR8/Qz97sosm1UlDRJ6qb6mQxQ8CFPsk6IEhnmPjizXxtmbS9N1dbfHyQ9gN
         EZslqHdApkDIdO58ck2NgBfseE/mRYI7O3+U2DVXMEBxGY0kpGyiEj5N49UCAASuJ9BL
         J1lw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
X-Gm-Message-State: APjAAAWk2AA+v/W6q7MwJ9J9c2/WutTvCKNTlYk1DeI3NvFvS1zxRzrA
	ipymxyt7oH0LWTfQ7gXS+ZYo3X/21YIrNr/3lYZDdf0Z4KuKeFmr7RGmYQuc1s83ZUv4B5XAWcl
	IS9CBhNFiJOowz7lZ0+yNLepoQIyjDR4jXDClfYXNOm4/ApMGm+eJ1JdF8gmLjTk1Yw==
X-Received: by 2002:a9d:7d0b:: with SMTP id v11mr16410206otn.270.1557151561659;
        Mon, 06 May 2019 07:06:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzsej5wj/+jLLJsnRGVZDNfGHgTJV/nPLUdBL9P0w1c+pi2VCtEn1pqC61+dE/Q24Ii93n
X-Received: by 2002:a9d:7d0b:: with SMTP id v11mr16410104otn.270.1557151560086;
        Mon, 06 May 2019 07:06:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557151560; cv=none;
        d=google.com; s=arc-20160816;
        b=zv7xblj+y77E7IHHJHrUL/UaZg0Xr7lWo082u+75II96yj8Zhtn6RpUjdasi+byvqM
         BxVzIu6gQ6grW74+qPRWdWvQT2ZR8SHgZoApHtj51MWpZBKy9uO9uGZwCgXMhUJtwsRf
         HQKC7zCVjOplvlaSbu8M9URxwkZn2DiwNpOysqsU9PsFbXL0rmJf456Z1UK/qEOcaTVu
         JNxv1HAH1X4NBMMP9ANq5S0u86rFS9hwjSvh4C245tmMpxelu0fHYdRB5WyBRspJb0Yv
         bg5c+YSWjKiF08/4QGwlAV2kR4XTl4u6tm5I5uX87EIrcOIzjKPoxH4Jk0AluiDpo1DR
         piIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject;
        bh=v0ZpZthk7KC02tnE2qOshb5LHR8NT8ZwOlhQdJj64P4=;
        b=Tk/iY6DF/ylcLe0icqKZjjqI7ZRShzI9uSRf1/VBJX6r+h10WV7p7VYQLoGwnbZkih
         MU85SiXnTPN4IjKijvd5pPZJhqE8ELVSMTTBkG4wZ7J6+i/oVpM3auMxKYSMugtwaOR2
         wCEKkGhTx6C1Yl35pcqP1EjUVweerdHA88ZdrBUJWOrEf2YWO2Rd5jKrIlxLzLL0It7b
         n0HfR7k2CW1s9kZeXdIJB2e/vyVukU5TqXj2yxZqup75Yyd7RzRDVZhFivNzgwk1+4kS
         Z5dGKbVfiUxo6U2pPuZfF/S2zxxRL3RSn6Ts5H2iONk+wHoIKdPEsbFBhAdtmK9VW4ak
         uvgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id h18si5209860otr.12.2019.05.06.07.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 07:06:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
Received: from DGGEMS411-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 8BC805C34C77B0AC26C3;
	Mon,  6 May 2019 22:05:54 +0800 (CST)
Received: from [127.0.0.1] (10.184.225.177) by DGGEMS411-HUB.china.huawei.com
 (10.3.19.211) with Microsoft SMTP Server id 14.3.439.0; Mon, 6 May 2019
 22:05:47 +0800
Subject: Re: [PATCH] mm/hugetlb: Don't put_page in lock of hugetlb_lock
To: Michal Hocko <mhocko@kernel.org>
CC: <mike.kravetz@oracle.com>, <shenkai8@huawei.com>, <linfeilong@huawei.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <wangwang2@huawei.com>,
	"Zhoukang (A)" <zhoukang7@huawei.com>, Mingfangsen <mingfangsen@huawei.com>,
	<agl@us.ibm.com>, <nacc@us.ibm.com>
References: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
 <20190504130137.GS29835@dhcp22.suse.cz>
From: Zhiqiang Liu <liuzhiqiang26@huawei.com>
Message-ID: <d82df01c-09e8-4e3d-4e01-d4df87936f75@huawei.com>
Date: Mon, 6 May 2019 22:05:45 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190504130137.GS29835@dhcp22.suse.cz>
Content-Type: text/plain; charset="gbk"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.225.177]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Sat 04-05-19 20:28:24, Zhiqiang Liu wrote:
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

>> Fixes: 9980d744a0 ("mm, hugetlb: get rid of surplus page accounting tricks")
>> Signed-off-by: Kai Shen <shenkai8@huawei.com>
>> Signed-off-by: Feilong Lin <linfeilong@huawei.com>
>> Reported-by: Wang Wang <wangwang2@huawei.com>
> 
> You are right. I must have completely missed that put_page path
> unconditionally takes the hugetlb_lock for hugetlb pages.
> 
> Thanks for fixing this. I think this should be marked for stable
> because it is not hard to imagine a regular user might trigger this.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thank you for your reply.
I will add Acked-by: Michal Hocko <mhocko@suse.com> in the v2 patch.


