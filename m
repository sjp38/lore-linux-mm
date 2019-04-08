Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E06A4C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 04:10:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A85AB208E3
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 04:10:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A85AB208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18BB96B0273; Mon,  8 Apr 2019 00:10:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13BA26B0274; Mon,  8 Apr 2019 00:10:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0025B6B0275; Mon,  8 Apr 2019 00:10:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8F0C6B0273
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 00:10:55 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id v10so5122482oie.4
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 21:10:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=b5sznIioWGEpJugfwCT/wZ++mYHhvA/9vVZtqOrlnM8=;
        b=phElmQTzCWuAgSulZrRDGW3YjiuxBY34CzqgF32tkb/7+7TYcyd/tPO6YGMYYt7cHM
         LKIInwyY775YM4IehrfzUZ/6kWLSIg++ORfzN+1CDXc+qEbVkg13ZtPp5r1ME73JmhoW
         BZViEFFFxXZ7xZIXc+rg9vJk2Fm5BT4kFt7GSw9DZn1FEWkvSyiNQIR4YHpovzbnl/cQ
         Mko3rzXrDdbkqyESvyDLW60az5M8h3WKlmZoxaJw5pya6MVt4eXtaEvCyeQDxXyQIDC4
         JlYKI72PI1/6XgczuL30yKYn7hLXv9LComTeIHXfylHhkmc0ae1SdIk5Oa50VVCBIHYz
         G07g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAXoHfUN6xewIovcErTMVrm4b/5hNsLwzDCP2jf2UVPwBHJC6qyM
	KpN3BVldiYcAN8woWYTWFAcjaAP3MfPbszmdtVl/RC3YuRga6tzg8Bn9Ml4nPeGh3lDzND8H+3B
	aRyaWqA/cQEBZUBkW3PafNkKAC9VRkmowqecDtQUZ5CEybUzIHEpT1bt2CUn9qbplkQ==
X-Received: by 2002:a9d:63d5:: with SMTP id e21mr17023655otl.288.1554696655540;
        Sun, 07 Apr 2019 21:10:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8C0PxEd875aUdtr+GPXnxdpiyJlS1zPXbWgmyn1Nw64njVH1dDobkfq4+BF74ZNie1/p4
X-Received: by 2002:a9d:63d5:: with SMTP id e21mr17023639otl.288.1554696655005;
        Sun, 07 Apr 2019 21:10:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554696655; cv=none;
        d=google.com; s=arc-20160816;
        b=Xh5OnYubHQ+0nnJPgZ87Z+zkjieELMAZew2xohmTFPiiXFnj1PtcKdVItFF1HM94MZ
         eOM8oNPwf9NoXMOH2pFWdwl7NHby2JGi77qKMh9BBHVg51pQM7dcQfZvdegsIA1oXSuY
         UIv4oz/Frg6RJn2Wie1vLrK4m6IwR/g6DJWStTzqZznrOHdr27By6h6zADox2Uj06ULh
         RpTCG8DUs04N4l/KDG7RlBbx72Sy3qWQhwY5tlZwg8U1nHvh9HBmzgyB+BBbZPVDRrga
         32gBQE70/Vg+bpdQeemcn8yCjH7/I7CybHtVbnvpf511eQqk+lmRR596xMrPa94JRwV0
         2YVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=b5sznIioWGEpJugfwCT/wZ++mYHhvA/9vVZtqOrlnM8=;
        b=l3WE9NRpygBxdMf7wJnMxBRpgit2ddBcFSCFaHk2GTpdYPiWZN2AAQWR8ahum1fb5K
         cZRySV57IMv3sWpN7n2ZB7BAu191EzeRSGxiB9jK1TTCw3hOIiyAS9L0tWiAffYPvQaY
         PWIOu7DsKW2YPGqzflfq0dXaMnonyYpxwA/4N15PKxfhYBg8p9Pb85ou4EAgYkgwktHh
         Uu77hWiUfQUwGh8MVADqou+awNlUa4Rj8WFp+Nvhx6X5F7s+RNoaO7iZmU+TeWewGuT0
         5IgA6XL+hppfWk8hQK+R9C1hqsh1V8xiTeLdpH7naq0Fu2ah/g3sV/YGssrwOaWYf/TM
         2RvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id y198si12227290oie.112.2019.04.07.21.10.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 21:10:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS404-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 55C5DACF789DC3F79613;
	Mon,  8 Apr 2019 12:10:49 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS404-HUB.china.huawei.com
 (10.3.19.204) with Microsoft SMTP Server id 14.3.408.0; Mon, 8 Apr 2019
 12:10:39 +0800
Message-ID: <5CAAC9BD.5080400@huawei.com>
Date: Mon, 8 Apr 2019 12:10:37 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: <akpm@linux-foundation.org>, <rafael@kernel.org>, <david@redhat.com>,
	<rafael.j.wysocki@intel.com>, <mhocko@suse.com>, <osalvador@suse.de>
CC: <vbabka@suse.cz>, <iamjoonsoo.kim@lge.com>, <bsingharora@gmail.com>,
	<gregkh@linuxfoundation.org>, <yangyingliang@huawei.com>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
Subject: Re: [PATCH] mm/memory_hotplug: Do not unlock when fails to take the
 device_hotplug_lock
References: <1554696012-9254-1-git-send-email-zhongjiang@huawei.com>
In-Reply-To: <1554696012-9254-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I am sorry,  It is incorrect.  please ignore the patch.  I will resent it.

Thanks,
zhong jiang
On 2019/4/8 12:00, zhong jiang wrote:
> When adding the memory by probing memory block in sysfs interface, there is an
> obvious issue that we will unlock the device_hotplug_lock when fails to takes it.
>
> That issue was introduced in Commit 8df1d0e4a265
> ("mm/memory_hotplug: make add_memory() take the device_hotplug_lock")
>
> We should drop out in time when fails to take the device_hotplug_lock.
>
> Fixes: 8df1d0e4a265 ("mm/memory_hotplug: make add_memory() take the device_hotplug_lock")
> Reported-by: Yang yingliang <yangyingliang@huawei.com>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  drivers/base/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index d9ebb89..8b0cec7 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -507,7 +507,7 @@ static ssize_t probe_store(struct device *dev, struct device_attribute *attr,
>  
>  	ret = lock_device_hotplug_sysfs();
>  	if (ret)
> -		goto out;
> +		goto ret;
>  
>  	nid = memory_add_physaddr_to_nid(phys_addr);
>  	ret = __add_memory(nid, phys_addr,


