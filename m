Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 677A8C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 13:58:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28B2020717
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 13:58:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28B2020717
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9795F6B027D; Mon, 27 May 2019 09:58:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92B106B027E; Mon, 27 May 2019 09:58:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F2DC6B027F; Mon, 27 May 2019 09:58:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5335C6B027D
	for <linux-mm@kvack.org>; Mon, 27 May 2019 09:58:30 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id x23so8848075otp.5
        for <linux-mm@kvack.org>; Mon, 27 May 2019 06:58:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=rbJlnYa7bR8IixIQV45NuiieODr6ig8AjY5FOCblSXs=;
        b=I69zCiQIT1TLew7mp91pwYFevPeWLXi3Qt4OxIG72uHtHSb08cj1Y99dkCxG6RaUCf
         sMZCzRjVXHMrPWfOZlURIu5j3jV9GBTpCNimdg7zQhL8KGexMmMV810r0rd4WZFxgaS7
         ZgUvdtWrZ3zyGlmqkFWH9M1o/ZZcVXJnUMdSRUstEcZ9B3vO3gxUAO9wMk5TKK5UAxK3
         C53OqYImeym158y3bK5k3BSBdhfgVmBZcmeHhTmeS2Is6awdiUclCbfDogtNn3KZssYg
         C37cPDqd6mw3TAm/CvswEUhqI6dZMHel3Xo9C66pCH0Z9x23crTeLiMqFScDNQWUEQG4
         +ZDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAUNBO35chX7kxOwLN0k9FjX3B4bbL3xm7oEpuayCdah70sQUxXf
	Al0BLs5EtC1l2U9xuz9mVXVT3H2ADSyOYjdpEVowmXJh7/BK/m8g8eqJYPkQKnXX7SrfKlBROph
	XvRy3oOArzhC35f6aps7tGLet/VUdj5/xqsEomSKLA1PP9p8zjUuB4uDO/KCh/mysQw==
X-Received: by 2002:a9d:7e88:: with SMTP id m8mr39262782otp.358.1558965510011;
        Mon, 27 May 2019 06:58:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdWpiapZwtUSpXRJoyX11DnY6BqHTx5+54XfvH8QV/ljuP75K2CE6KMoDvITsTMtSvJfHX
X-Received: by 2002:a9d:7e88:: with SMTP id m8mr39262716otp.358.1558965508405;
        Mon, 27 May 2019 06:58:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558965508; cv=none;
        d=google.com; s=arc-20160816;
        b=Xc2iRDeRoqK8G61Xy/RHJU+pGy8rOW7OTPeV1QdSVzEsnb/3ldMW+n/4MvzWYvbD2W
         qVfwJ4X6E4foC0FbwROAElYqY8gD+dNnvpbr9RNig7vQu4cf4igCDUufhN7hYCOFswSF
         eUdkzHRzl6ZV3tywL9yWd6UKoY2OgpfJ9mw2I+iIr/X87NuJVbQ2H3zVwnL5YxoO80yf
         Zj7cD6+rf7Ej5eJYu9GKYXRWiiONhG3vshxa4HJEa4pWQp8TkxkwEO7Qcf/c601RR1Fu
         KRl58CRRtOPffGF8pMp1Ir2ya68LVfLFvIvMOfbhhhmAuMT7+2BLASVFsocbINuyu/Bo
         PP3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=rbJlnYa7bR8IixIQV45NuiieODr6ig8AjY5FOCblSXs=;
        b=amDZtVrCQupAauI2HHjLGB2pPC6pmeSAs3qxR5FlobMd8Xed89FmyK+aZL8UEwGQxq
         sOsIYHxPwpqeZ7OO23IVuWr2bhuZgvujNYKFQnXUexTE2FjwEyt1LfjMIRosLSS5hMC4
         90H1q7HKnrMAZa0JDLv5IfAYVQR3nhqKP3acSqENrkUByWFyrcyZbHmki1h7O18ztllH
         ocL3vAtXf6/V647FR6TfcClh0Mu3v2WNxzGenZvB4Dxq1X19SK9QgPByH8mR1HzcF2W/
         X2XIFv1wwPS7ll9ot7Y4SmO16ONMw7ICEA78GlEF4XjHBbW43RnJseVtenbM7Kk3WxYK
         2vvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id v17si5708841otj.162.2019.05.27.06.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 06:58:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id A18F1DA764C56511616F;
	Mon, 27 May 2019 21:58:22 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS409-HUB.china.huawei.com
 (10.3.19.209) with Microsoft SMTP Server id 14.3.439.0; Mon, 27 May 2019
 21:58:18 +0800
Message-ID: <5CEBECF9.2060500@huawei.com>
Date: Mon, 27 May 2019 21:58:17 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Vlastimil Babka <vbabka@suse.cz>
CC: Andrew Morton <akpm@linux-foundation.org>, <osalvador@suse.de>,
	<khandual@linux.vnet.ibm.com>, <mhocko@suse.com>,
	<mgorman@techsingularity.net>, <aarcange@redhat.com>, <rcampbell@nvidia.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/mempolicy: Fix an incorrect rebind node in mpol_rebind_nodemask
References: <1558768043-23184-1-git-send-email-zhongjiang@huawei.com> <20190525112851.ee196bcbbc33bf9e0d869236@linux-foundation.org> <2ff829ea-1d74-9d4b-8501-e9c2ebdc36ef@suse.cz>
In-Reply-To: <2ff829ea-1d74-9d4b-8501-e9c2ebdc36ef@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/5/27 20:23, Vlastimil Babka wrote:
> On 5/25/19 8:28 PM, Andrew Morton wrote:
>> (Cc Vlastimil)
> Oh dear, 2 years and I forgot all the details about how this works.
>
>> On Sat, 25 May 2019 15:07:23 +0800 zhong jiang <zhongjiang@huawei.com> wrote:
>>
>>> We bind an different node to different vma, Unluckily,
>>> it will bind different vma to same node by checking the /proc/pid/numa_maps.   
>>> Commit 213980c0f23b ("mm, mempolicy: simplify rebinding mempolicies when updating cpusets")
>>> has introduced the issue.  when we change memory policy by seting cpuset.mems,
>>> A process will rebind the specified policy more than one times. 
>>> if the cpuset_mems_allowed is not equal to user specified nodes. hence the issue will trigger.
>>> Maybe result in the out of memory which allocating memory from same node.
> I have a hard time understanding what the problem is. Could you please
> write it as a (pseudo) reproducer? I.e. an example of the process/admin
> mempolicy/cpuset actions that have some wrong observed results vs the
> correct expected result.
Sorry, I havn't an testcase to reproduce the issue. At first, It was disappeared by
my colleague to configure the xml to start an vm.  To his suprise, The bind mempolicy
doesn't work.

Thanks,
zhong jiang
>>> --- a/mm/mempolicy.c
>>> +++ b/mm/mempolicy.c
>>> @@ -345,7 +345,7 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
>>>  	else {
>>>  		nodes_remap(tmp, pol->v.nodes,pol->w.cpuset_mems_allowed,
>>>  								*nodes);
>>> -		pol->w.cpuset_mems_allowed = tmp;
>>> +		pol->w.cpuset_mems_allowed = *nodes;
> Looks like a mechanical error on my side when removing the code for
> step1+step2 rebinding. Before my commit there was
>
> pol->w.cpuset_mems_allowed = step ? tmp : *nodes;
>
> Since 'step' was removed and thus 0, I should have used *nodes indeed.
> Thanks for catching that.
>
>>>  	}
>>>  
>>>  	if (nodes_empty(tmp))
>> hm, I'm not surprised the code broke.  What the heck is going on in
>> there?  It used to have a perfunctory comment, but Vlastimil deleted
>> it.
> Yeah the comment was specific for the case that was being removed.
>
>> Could someone please propose a comment for the above code block
>> explaining why we're doing what we do?
> I'll have to relearn this first...
>
>


