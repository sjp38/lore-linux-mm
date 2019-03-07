Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5533FC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 14:47:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A5A220835
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 14:47:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A5A220835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3A818E0003; Thu,  7 Mar 2019 09:47:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9997D8E0002; Thu,  7 Mar 2019 09:47:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 887E18E0003; Thu,  7 Mar 2019 09:47:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 33F118E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 09:47:02 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id y86so3576696lje.1
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 06:47:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=xoRw+osrSCsCgSX1uQFnhWklfRATS02g50iWFQy/cww=;
        b=IjhZQUR1VpR7+dH1ONvMibB6lLA1fviTzR6nL0K84Ci9urGeVCCNZ6B64Sl813AwpG
         tHgFGS29wygHXtd8nFuaCoA5B/4v+kZeWDqeHkEDk1OjaAmJzyaDzqX5mMMLmHMQhw8c
         5aRsm6RDZfR9q3/IL+ABnz7M+zKvtBOZ+0K0i0b7k40gaxhVzetRTFA4iAE0PNQnodWm
         wYmzugYysH/ljaZZd94tLAQFLASYzc1zXhpTgqmUeC0oQHmIXVjP0wYJ8TXz0KHJWEMw
         HuMzpbQYadq/wbRgpE3uiArYINg8wOrYyBTAEweG7UgTBu02qe9MTov4QnPrW+ckItfF
         Tb0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXZwBu92N5W8Nj3AusJJdLiBl8OVj0dUFItTQinYnGAILtN1oHG
	HnhUGKwqLVjMnd0cnuR9D1PuSUftu95herw0dCYE/Rma/guAEjzp+4oFQi4qee1v1YkpAxb3WSB
	uQpK87r/WO6WG7Mr9XmaZtXusLadfYAFvuNBKuPefFharD/W9aXA84/yvCPyyEKLz/w==
X-Received: by 2002:a19:d502:: with SMTP id m2mr7345372lfg.128.1551970021500;
        Thu, 07 Mar 2019 06:47:01 -0800 (PST)
X-Google-Smtp-Source: APXvYqxO9+zcLELbMM23Hv7JdwXzQCnWX+wcogwyIaSqqWE2TeayCfzA4sJU3L6XUR7weH6EzwMa
X-Received: by 2002:a19:d502:: with SMTP id m2mr7345331lfg.128.1551970020502;
        Thu, 07 Mar 2019 06:47:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551970020; cv=none;
        d=google.com; s=arc-20160816;
        b=gYD6PAPCxklW4A3iQ5bpyoj9IbIZ0Nfnakac9ul2HSZ02owo2dVVoTxq0jlC/o+fqy
         RgbBmb7ppjP+RNmbyBwvdh8twxEzlGda7SkSWQWO6iz1N978esJcs+I2TVlFu8IkaBj+
         66XsxFXULoVnOeH4gS4YQgb5WjopAVnAciFFbnogYUkCIPhj6H5Gk/Al59eia0NjiEG6
         1DXwbNM6kGWLqbz+8B+8Ch6jOR8lCJIP5ayyrtgu9TVB7K7y2FBOF3TUlztck8pLLsh3
         2tfI5tFLJmwoAt17M/2OSG2MF4cqwiJa8rFuWC4Ul9mpx/6/uA1Y9EXBbP4tqFJwtTUx
         wgdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=xoRw+osrSCsCgSX1uQFnhWklfRATS02g50iWFQy/cww=;
        b=SrB5cvdeZi4qV9gBewm+oK61EtvCu84mislYtP5toCnYm9jqmf+VWoBx4oLMwwzc4A
         mvmni/kKYrV4bR0mY11Yo3T1ZlmPQUjPa08DFvCLiMeehn3R07J3G2Ty4yYvbN/wHOuI
         ys4jRMR54C8nJABxmWsciEDu+0820MCfNBW0WL6k5jD2Ifyg6LE6eaPGo2xdhQyb64pv
         jy7FhhKtwvADk7imFQoerkDY4tsKGBnepf053M4Pp9DzVELEz2xT2JqgVo7JDjCre+vv
         nv2nH4HSGUJueqXBA9zeYqc4tNuVwZqzvOvVH9cXsMfPFRau7NUcYZfJziQPVCpqCoAi
         l4gw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id z6si3748158ljj.164.2019.03.07.06.47.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 06:47:00 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1h1uIL-0002CD-0A; Thu, 07 Mar 2019 17:46:49 +0300
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
To: Aaron Lu <aaron.lu@linux.alibaba.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Yang Shi <shy828301@gmail.com>, Jiufei Xue <jiufei.xue@linux.alibaba.com>,
 Linux MM <linux-mm@kvack.org>, joseph.qi@linux.alibaba.com,
 Linus Torvalds <torvalds@linux-foundation.org>
References: <b9781d8e-88f7-efc0-3a3c-76d8e7937f10@i-love.sakura.ne.jp>
 <CAHbLzkots=t69A8VmE=gRezSUuyk1-F9RV8uy6Q7Bhcmv6PRJw@mail.gmail.com>
 <201901300042.x0U0g6EH085874@www262.sakura.ne.jp>
 <20190129170150.57021080bdfd3a46a479d45d@linux-foundation.org>
 <20190307144329.GA124730@h07e11201.sqa.eu95>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <647c164c-6726-13d8-bffc-be366fba0004@virtuozzo.com>
Date: Thu, 7 Mar 2019 17:47:13 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <20190307144329.GA124730@h07e11201.sqa.eu95>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/7/19 5:43 PM, Aaron Lu wrote:
> On Tue, Jan 29, 2019 at 05:01:50PM -0800, Andrew Morton wrote:
>> On Wed, 30 Jan 2019 09:42:06 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
>>
>>>>>
>>>>> If we want to allow vfree() to sleep, at least we need to test with
>>>>> kvmalloc() == vmalloc() (i.e. force kvmalloc()/kvfree() users to use
>>>>> vmalloc()/vfree() path). For now, reverting the
>>>>> "Context: Either preemptible task context or not-NMI interrupt." change
>>>>> will be needed for stable kernels.
>>>>
>>>> So, the comment for vfree "May sleep if called *not* from interrupt
>>>> context." is wrong?
>>>
>>> Commit bf22e37a641327e3 ("mm: add vfree_atomic()") says
>>>
>>>     We are going to use sleeping lock for freeing vmap.  However some
>>>     vfree() users want to free memory from atomic (but not from interrupt)
>>>     context.  For this we add vfree_atomic() - deferred variation of vfree()
>>>     which can be used in any atomic context (except NMIs).
>>>
>>> and commit 52414d3302577bb6 ("kvfree(): fix misleading comment") made
>>>
>>>     - * Context: Any context except NMI.
>>>     + * Context: Either preemptible task context or not-NMI interrupt.
>>>
>>> change. But I think that we converted kmalloc() to kvmalloc() without checking
>>> context of kvfree() callers. Therefore, I think that kvfree() needs to use
>>> vfree_atomic() rather than just saying "vfree() might sleep if called not in
>>> interrupt context."...
>>
>> Whereabouts in the vfree() path can the kernel sleep?
> 
> (Sorry for the late reply.)
> 
> Adding Andrey Ryabinin, author of commit 52414d3302577bb6
> ("kvfree(): fix misleading comment"), maybe Andrey remembers
> where vfree() can sleep.
> 
> In the meantime, does "cond_resched_lock(&vmap_area_lock);" in
> __purge_vmap_area_lazy() count as a sleep point?

Yes, this is the place (the only one) where vfree() can sleep.

