Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ADD6C606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 01:52:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE9D3216C4
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 01:52:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE9D3216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35FB38E0039; Mon,  8 Jul 2019 21:52:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 310088E0032; Mon,  8 Jul 2019 21:52:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FEFB8E0039; Mon,  8 Jul 2019 21:52:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC43B8E0032
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 21:52:30 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id u8so6983678oie.5
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 18:52:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=a5yFBY7pHVz8ae/QG0yxiY7eGJLnhx0rUs3yxgKZoKI=;
        b=QWdKqLXPFIBRbGIeqpoEtgxTMh/GpYac2hmyr8VbDhHglPNWetgt+Hk0a2//FEdpW0
         mgOjZMpNkHgGDAG7ScZljWPnwcBJGuv49bQ06GfTO6Hwmrl0E4gV+mS6tnfqb7NiaOr3
         YVaNe/s1GaIDJx81qCIda4yBbbTZz5SIp6qAWZxQ80sYim27xG55LpUBCGlNGsXSCDIZ
         rQj3AL6+HnYtfHjed//n0DAhNP5F/GXeYnXzVgZoZt3jitixFbbJ83YTVRU3VIUHoajp
         HYP+S1KtBpoBIsvcsU/452NG1PgtwyIQeUHTLVbbf5cUa5t/mKmcQhxgMcWe2hy54qnK
         dHgg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAWWCJkfjwH2y1lI2QLRa8NPwgD3WwfZWA1OB/fuJajs+LEnkCq1
	Kcve9CC3enDLJbrAa6oi6V1RmYZOqWMkuRyHWv0JqvRpDOv9mkpu2YQzn8nTgS/papScCTwkwv/
	B1xqlQNRUN/WbEtblLuOUptdQTBSUD8TKc0DmiVx0K9tqT7Ewo7vjqaTjv3TUvEJ+IQ==
X-Received: by 2002:a9d:3d8a:: with SMTP id l10mr16102150otc.343.1562637150686;
        Mon, 08 Jul 2019 18:52:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlJZMI1oZ+9mMrQ34r6YYi7PKTKtTh7R+9Gkjy0MkgFDwihMYaZtzwb/wZsSgb5eAsGY2S
X-Received: by 2002:a9d:3d8a:: with SMTP id l10mr16102104otc.343.1562637149974;
        Mon, 08 Jul 2019 18:52:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562637149; cv=none;
        d=google.com; s=arc-20160816;
        b=iU1GtJN/AfUr65KXEhv1cGr74UJGAAjcnLcUQZaXPsG39IDpNK2ISorZG6JK5PbiRp
         RGusCM/kX3qPQAlqmMbJ/IlVH7TBwz83W6sGuJkYlb1ywrVbaSuippKDsF54aO23Iy7O
         9eWe3pKMDPPxN+vXVPs+pbPMQhb7aKUvO68Yb6cQCLhEH5jLqZTsNE59l5Lm2VTMiNwC
         +UvFkEmWGSF1pG+xDU6n/LS5/Aw3ovmA0Dp8fP80Czk+4RJ0ZPQSbPTsA3EAjhAHt9ur
         yO+mz2bE9k7ysoEF38UttmIeJHXo5NadSE9tNrmitA9M+REo4QcRU0AqRlgP3G3oRBD7
         SM2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=a5yFBY7pHVz8ae/QG0yxiY7eGJLnhx0rUs3yxgKZoKI=;
        b=Gj9+wtLRtU7+uBOajbxBEgTy4IGt3YfJqZ3viLjf1a4O6Vqi1MbYpReMYsTIMGU8WH
         hg5NWFqjuB204Dg/zkryaYiHCm2ZzwDKkRFFgVK3qK9+5CMLmzdb12xERDRZdb2727IN
         6KVD1+KHNmxEZs8mDydkbDc9CJvNVmfiv9FPGkqYGvb+Edn7S8w75ZKuUFpaP2AIgz6U
         zmzOoOt8z16OUL+skagAl1ozmeGJ7xHLyPCv9dtOHhWuSqYEn9QdjfurWHK7mgcpPo+k
         tNG+J7mUK/1wZXI8tFzj9M0Z1STvFWrsBjPKa/KxcQFKapIZCRBaRhEVz1veT+ExmudG
         aSFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id x65si13162319ota.295.2019.07.08.18.52.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 18:52:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS412-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 72E70655EBA4DF060396;
	Tue,  9 Jul 2019 09:52:24 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS412-HUB.china.huawei.com
 (10.3.19.212) with Microsoft SMTP Server id 14.3.439.0; Tue, 9 Jul 2019
 09:52:22 +0800
Message-ID: <5D23F356.6090705@huawei.com>
Date: Tue, 9 Jul 2019 09:52:22 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Michal Hocko <mhocko@suse.com>
CC: <akpm@linux-foundation.org>, <anshuman.khandual@arm.com>,
	<mst@redhat.com>, <linux-mm@kvack.org>, Dan Williams
	<dan.j.williams@intel.com>
Subject: Re: [PATCH] mm: redefine the MAP_SHARED_VALIDATE to other value
References: <1562573141-11258-1-git-send-email-zhongjiang@huawei.com> <20190708092045.GA20617@dhcp22.suse.cz> <5D234AB5.2070508@huawei.com> <20190708164314.GE20617@dhcp22.suse.cz>
In-Reply-To: <20190708164314.GE20617@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/7/9 0:43, Michal Hocko wrote:
> On Mon 08-07-19 21:52:53, zhong jiang wrote:
>> On 2019/7/8 17:20, Michal Hocko wrote:
>>> [Cc Dan]
>>>
>>> On Mon 08-07-19 16:05:41, zhong jiang wrote:
>>>> As the mman manual says, mmap should return fails when we assign
>>>> the flags to MAP_SHARED | MAP_PRIVATE.
>>>>
>>>> But In fact, We run the code successfully and unexpected.
>>> What is the code that you are running and what is the code version.
>> Just an following code, For example,
>> addr = mmap(ADDR, PAGE_SIZE, PROT_WRITE|PROT_EXEC, MAP_SHARED|MAP_PRIVATE, fildes, OFFSET);
> Is this a real code that relies on the failure or merely a simple test
> to reflect the semantic you expect mmap to have?
>
>> We test it and works well in linux 4.19.   As the mmap manual says,  it should fails.
>>>> It is because MAP_SHARED_VALIDATE is introduced and equal to
>>>> MAP_SHARED | MAP_PRIVATE.
>>> This was a deliberate decision IIRC. Have a look at 1c9725974074 ("mm:
>>> introduce MAP_SHARED_VALIDATE, a mechanism to safely define new mmap
>>> flags").
>> I  has seen the patch,  It introduce the issue.  but it only define the MAP_SHARED_VALIDATE incorrectly.
>> Maybe the author miss the condition that MAP_SHARED_VALIDATE is equal to MAP_PRIVATE | MAP_SHARE.
> No you are missing the point as Willy pointed out in a different email.
> This is intentional. No real application could have used the combination
> of two flags because it doesn't make any sense. And therefore the
> combination has been chosen to chnage the mmap semantic and check for
> valid mapping flags. LWN has a nice coverage[1].
Thanks you for pointing out.   I will look at the patch deeply.

Sincerely,
zhong jiang
>
> [1] https://lwn.net/Articles/758594/


