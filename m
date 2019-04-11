Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3433C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:55:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EC142077C
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 14:55:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EC142077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E01786B0010; Thu, 11 Apr 2019 10:55:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAF286B0266; Thu, 11 Apr 2019 10:55:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C51416B0269; Thu, 11 Apr 2019 10:55:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A53C96B0010
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:55:18 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x23so5252741qka.19
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:55:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=e5yJ1jZtaUVS1Fv58pGovSMfvhvUYLW2P+N1LeZDGto=;
        b=rcIWdJB1c2weAoXBbli/01T3RIkw2tyegv5NdTjI0QQrQ8N2xrGphyQiYYB0yxG8GG
         x5CvkIJu+Oq0aMT/ndta8idcjriSnIrRCfEq4TotBXNf1kldi2ipVCfVFllhrrmCeStp
         y/y5+ulbP2DgdoGE+IYJnXwDYgbExtx95/g3SG6vNsikmWoZZugGLFLypYRHxPD89DHO
         5b/4JwgKPREoGtYyuzyb36SH2xLBlNYfzrqFbA39gK2RUIyL3XHQHFMCD1msPBgFUtz6
         kYbXhm3R2epnEGuOEtlejgoTE1F/es/VebSO25jAs/82qW7ACGVOvuKbKZFf/cUdQhae
         KXQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW0t32eNjVmRbtx0CEpzWX1hMcCAvaso+YMlghu8164cNEx9ZRX
	5spMaQYy93JPykGszlBpZ0rEWrXoX7JJttbemviD/45L1FQAXOw2qm9YHAsJ5JAgY8Z6a5ETupw
	Y/7f8LZ+KXMZzb0TYye9UpO0F6oyGhHI4QXZDmXHlFJu/uqW7T4VWLH7te7E5IePEbg==
X-Received: by 2002:ac8:2684:: with SMTP id 4mr43991335qto.67.1554994518394;
        Thu, 11 Apr 2019 07:55:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFW4BNbmlNG5f06xiKRNUNNwrZ5IwdXVyBvqZ8eeALogNZHPcAE8ozfUR9cN5gUZSWFz9o
X-Received: by 2002:ac8:2684:: with SMTP id 4mr43991253qto.67.1554994517252;
        Thu, 11 Apr 2019 07:55:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554994517; cv=none;
        d=google.com; s=arc-20160816;
        b=D6XmViK8ZI+vPzpSTWSUs4bJyI+CPe1IjSuO9D3xjvNmtKTNpJRa8JzQQE/CmsTGx4
         9cgMEqV4TnlfacBMdJt+OZiKrVwRsL+qZLAvR3lzA6POx195DxRV1mb04KIThiB0L6Gw
         3DSpXkDuNx7yfDxhgZ+Vb6UVxVKBKmZaUikCRkGnPIGe5NVY/vBSPOFmpZ/voRjxnYTT
         EUNJz6r6rv4d5++A0DvDJvPMg3+ctffveDl0es1RD9cDv/uYZCibbTE49XdqM9eqpXIg
         6FHwpEllQae7BuAxmwuQzwnRo68Fs+NLeqf3t5PbDPqH8qX98BFXX5EQ0liB7LRASkUL
         6YpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=e5yJ1jZtaUVS1Fv58pGovSMfvhvUYLW2P+N1LeZDGto=;
        b=v9tVKOERzoojM1pFlekNnvS0F9G7Y7H9c1StkKTfM79tg2SkxEsKtzOMzy+ai1TF2u
         XXkbGxlfSlT7wI9p4tSr+PD7IlvY5yz1aI8ZDbmPPEKmxZDqmBdkKA1mBsWWwe7p9dZ3
         lva1pVf9XjPu1+ZZ+A8bD5Axj3wSNSNQM63rBtKxuQ4lbaH7AHwwdv6FYSbIuyEU1hb9
         5Yeq9ApnO4PgyN+XWThJRsAnFVWrTY0u3ccySf2/ZJnv+PF/XtO9D0m+FS14+J/fX6Zi
         EjNqGZ6RavYKSyP7v0aVrcoV/8Ayd+afZ8q89ij7cVC1q0N5fsZ5sZ7lKuw4zXWeKKd0
         /CMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z24si728117qta.69.2019.04.11.07.55.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 07:55:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B69158E581;
	Thu, 11 Apr 2019 14:55:06 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-47.bos.redhat.com [10.18.17.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7F02D17F22;
	Thu, 11 Apr 2019 14:55:02 +0000 (UTC)
Subject: Re: [RFC PATCH 0/2] mm/memcontrol: Finer-grained memory control
To: Kirill Tkhai <ktkhai@virtuozzo.com>, Tejun Heo <tj@kernel.org>,
 Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
 Shakeel Butt <shakeelb@google.com>, aryabinin@virtuozzo.com
References: <20190410191321.9527-1-longman@redhat.com>
 <1b6ee304-6176-15a0-c3fa-0b59cdd60085@virtuozzo.com>
From: Waiman Long <longman@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=longman@redhat.com; prefer-encrypt=mutual; keydata=
 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
 weim8xU=
Organization: Red Hat
Message-ID: <cea941ed-f401-7380-6e48-622115a02533@redhat.com>
Date: Thu, 11 Apr 2019 10:55:01 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1b6ee304-6176-15a0-c3fa-0b59cdd60085@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 11 Apr 2019 14:55:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/11/2019 10:37 AM, Kirill Tkhai wrote:
> On 10.04.2019 22:13, Waiman Long wrote:
>> The current control mechanism for memory cgroup v2 lumps all the memory
>> together irrespective of the type of memory objects. However, there
>> are cases where users may have more concern about one type of memory
>> usage than the others.
>>
>> We have customer request to limit memory consumption on anonymous memory
>> only as they said the feature was available in other OSes like Solaris.
>>
>> To allow finer-grained control of memory, this patchset 2 new control
>> knobs for memory controller:
>>  - memory.subset.list for specifying the type of memory to be under control.
>>  - memory.subset.high for the high limit of memory consumption of that
>>    memory type.
>>
>> For simplicity, the limit is not hierarchical and applies to only tasks
>> in the local memory cgroup.
>>
>> Waiman Long (2):
>>   mm/memcontrol: Finer-grained control for subset of allocated memory
>>   mm/memcontrol: Add a new MEMCG_SUBSET_HIGH event
>>
>>  Documentation/admin-guide/cgroup-v2.rst |  35 +++++++++
>>  include/linux/memcontrol.h              |   8 ++
>>  mm/memcontrol.c                         | 100 +++++++++++++++++++++++-
>>  3 files changed, 142 insertions(+), 1 deletion(-)
> CC Andrey.
>
> In Virtuozzo kernel we have similar functionality for limitation of page cache in a cgroup:
>
> https://github.com/OpenVZ/vzkernel/commit/8ceef5e0c07c7621fcb0e04ccc48a679dfeec4a4

It will be helpful to know the use case where you want to limit page
cache usage. I have anonymous memory in mind when I compose this patch,
but I make the mechanism more generic so that it can apply to other use
cases as well.

Cheers,
Longman

