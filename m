Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 286AAC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:35:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9A2D217D4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:35:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9A2D217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68EC06B000D; Thu, 11 Apr 2019 11:35:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63F2E6B000E; Thu, 11 Apr 2019 11:35:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52E606B0010; Thu, 11 Apr 2019 11:35:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id E24E16B000D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:35:09 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id c21so1484197lji.18
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:35:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=wA/Cn3a1KpWMhrPejnVrHrnQhy/DaRHrDxTRg9jzhL0=;
        b=RkgT9pba9PryKF2sEjoH1eQBzh72y2yY9nnWlNZl2BAuWwpnT2UZW5yujQQB+gGGaw
         ahHWYpU/lVRXVkTtiqe3g2RqyrxsZw8mJf4RBwaesLzjby5EAEq4fs8ORZitWCJiMmlm
         VInl1+r6ea9zmepdJsBypMQdozSzlU7FVQ1FGrENrdGa6v903+L1c+R4KqyAO6Hk09b1
         bvoKiTGHrODBlVxX074YCh2zP1jZEROo8+fMhpGZxMCkpUjUqRd7m2+efpTQiR7shOUf
         QciRopopdv9SpD+eisXZ1tKMLhC/Nim+uJz3ztN/xpcvJA/+HaKcOfVkDZCrLxwNhNlt
         Zomg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVrPtMm7M7S7Z4yuTkf1XW/0w9hMO34Q1duE3mSUz/+d0FVG3Fo
	OuKYsO2K1BhXVRM9Pw8vG8PYbs8u464cJERWEwKRfycNHEtnRYgr4VeZMlBrTo9WxOgF0H/p5D4
	dvhXDBwgtBlaAknEtFAtd0ovAjfTIBRybJkHWKt3lcxF0Powocj5S+51vdtlh/Mushw==
X-Received: by 2002:a2e:9812:: with SMTP id a18mr23954544ljj.146.1554996909123;
        Thu, 11 Apr 2019 08:35:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUBhdjgHa77WywnDxurFjG5G303BhkBh1F1TdCtQnaxhN/lYdL0bZlBb07c7XoedwleiTP
X-Received: by 2002:a2e:9812:: with SMTP id a18mr23954513ljj.146.1554996908271;
        Thu, 11 Apr 2019 08:35:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554996908; cv=none;
        d=google.com; s=arc-20160816;
        b=hUkEpBD59BW9JsV1r/u0ds//l7gLORJcTotW4nY5DVNOETYdNKCKRmjWpU2xPxPfhR
         77bUiW+yXvrGg8NBDQAsZZw0BjnR57nqQLcknOZoxJdZuTZhan3/4GVS+mwwBkTahtiB
         /ZRuVFUFxkNj5P9eAs6EMKgzXJwlKFnZTUsQtCfdncbSrw5dJioqGsnHEDS9NhhDzSzo
         96sm9vuiPcOySWz2Q/Ka6SF15LDzfF/X3fi2/oCUzlicjMHCraCePv/u726gyDo91sZi
         hRvHL4wLlqmNYwYESMDqKOdskayMzwKCAJulkfpbQBcw+Z6KUSL9yJ8z8YA2i/KhDA/G
         Zjgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=wA/Cn3a1KpWMhrPejnVrHrnQhy/DaRHrDxTRg9jzhL0=;
        b=GZEfQvBgTYH2VN6L8N5780Ezv+0d/2BBOCEHtY1zB+5Hs/0gTF8gTwY6MNMDqg6Mmp
         KGyD+VpaE/NGaLuy/o8hpJFrTHyxUXjvOJyHE4nXCjL9C5ATh8w0xE//fei2llqQbeKq
         8oBzmhLm0VeSJEizNwh6viFQtJcVpynpneOlU0ikjR6WsKxU4jLmLbOcvLbuh0PBVjVD
         fA3MZVLwSUgZ53xlMFkn8t7/TuMudNLsk2PzoI5Jto+/5RhMsAlKs7EBhBgJMfsnzje9
         62+13F1efqDwDdX0+daC0j9b956mN10yYzBIjfuPDw9HNzyYkT4k40U1eA2gJxmY6NoM
         hiJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id r23si22133758lfm.62.2019.04.11.08.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 08:35:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hEbjA-0003Qf-Fc; Thu, 11 Apr 2019 18:35:00 +0300
Subject: Re: [RFC PATCH 0/2] mm/memcontrol: Finer-grained memory control
To: Waiman Long <longman@redhat.com>, Tejun Heo <tj@kernel.org>,
 Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>,
 Shakeel Butt <shakeelb@google.com>, aryabinin@virtuozzo.com
References: <20190410191321.9527-1-longman@redhat.com>
 <1b6ee304-6176-15a0-c3fa-0b59cdd60085@virtuozzo.com>
 <cea941ed-f401-7380-6e48-622115a02533@redhat.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <d8fc644e-0e83-7925-e728-34f6fc016f98@virtuozzo.com>
Date: Thu, 11 Apr 2019 18:35:00 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <cea941ed-f401-7380-6e48-622115a02533@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.04.2019 17:55, Waiman Long wrote:
> On 04/11/2019 10:37 AM, Kirill Tkhai wrote:
>> On 10.04.2019 22:13, Waiman Long wrote:
>>> The current control mechanism for memory cgroup v2 lumps all the memory
>>> together irrespective of the type of memory objects. However, there
>>> are cases where users may have more concern about one type of memory
>>> usage than the others.
>>>
>>> We have customer request to limit memory consumption on anonymous memory
>>> only as they said the feature was available in other OSes like Solaris.
>>>
>>> To allow finer-grained control of memory, this patchset 2 new control
>>> knobs for memory controller:
>>>  - memory.subset.list for specifying the type of memory to be under control.
>>>  - memory.subset.high for the high limit of memory consumption of that
>>>    memory type.
>>>
>>> For simplicity, the limit is not hierarchical and applies to only tasks
>>> in the local memory cgroup.
>>>
>>> Waiman Long (2):
>>>   mm/memcontrol: Finer-grained control for subset of allocated memory
>>>   mm/memcontrol: Add a new MEMCG_SUBSET_HIGH event
>>>
>>>  Documentation/admin-guide/cgroup-v2.rst |  35 +++++++++
>>>  include/linux/memcontrol.h              |   8 ++
>>>  mm/memcontrol.c                         | 100 +++++++++++++++++++++++-
>>>  3 files changed, 142 insertions(+), 1 deletion(-)
>> CC Andrey.
>>
>> In Virtuozzo kernel we have similar functionality for limitation of page cache in a cgroup:
>>
>> https://github.com/OpenVZ/vzkernel/commit/8ceef5e0c07c7621fcb0e04ccc48a679dfeec4a4
> 
> It will be helpful to know the use case where you want to limit page
> cache usage. I have anonymous memory in mind when I compose this patch,
> but I make the mechanism more generic so that it can apply to other use
> cases as well.

We have distributed storage, and there are its daemons on every host.
There are replication factor 1:N, so the same block may be duplicated
on different hosts. They produce a lot of pagecache, but it is reused
not often (because of the above 1:N).

So, we want to limit pagecache, but do not limit anon memory. This
prevents global reclaim, and we found this improves our performance tests.

Kirill

