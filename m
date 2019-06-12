Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31178C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:14:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB37C21019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:14:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB37C21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E8386B026D; Wed, 12 Jun 2019 13:14:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9979D6B026E; Wed, 12 Jun 2019 13:14:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AEBE6B026F; Wed, 12 Jun 2019 13:14:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 56EAF6B026D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:14:13 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b127so12440742pfb.8
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:14:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=K8Zv8V52zsSx5OIu0AN8ygd1P9iRWZrB9jtIJM4wgqY=;
        b=NmZsir9n/XW+UeZT2Ualdpc3tY9GSowLIyXFECcFswu6gXodbld72K7Yvf+M5ogFDe
         WGXyPwJWCRyfr8yb/5tZQvXzWVqIh6nOPYcaN+xYQWrgD+nuXK2xC9oIs55aq11w+rhJ
         I/VuSAicSApH5MnVqGeRhwmztjPghClnzoQ6tYlUypYxvLLwENpGhg8rvAPc15yWBJeY
         cTq7u4ajIK9cCfPaBiJT6mEUc/cOZyimGD9yMx76ECzOl0Ae2ro3H9k1CaWsRQyyZKN0
         MneNaPTkYpnTEkomM3DXTswNbuDFveoJsdaglUUKegA+tFHcma0OlGijgq1fotsYgiLr
         7y8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXjmAdtxHGsHIOaFw51rGJSHlBeBtQC+Nn7AqqJoApqiprHsot/
	ynQZvbLQHv9RDIZXrBWyCsv5YE36tovcMTTYcCFQuy/PbUWkaN+pFosvDRnQo5MePblaw0Uqvv1
	wdkP8/P2IJm1HaX6b8hcgsOwoJ1ymGzhME/TxG5gO9YfesxBeuM9b5C4a/EyBGNw5Jw==
X-Received: by 2002:a17:90a:206a:: with SMTP id n97mr277531pjc.10.1560359653024;
        Wed, 12 Jun 2019 10:14:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzv/ZnPIdaaEGGN5eQYe2yAd9dRD2AvVCWZ44dB5xPq+jtI8KGnhjd7F83kmCK+g2r42ElW
X-Received: by 2002:a17:90a:206a:: with SMTP id n97mr277469pjc.10.1560359652160;
        Wed, 12 Jun 2019 10:14:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560359652; cv=none;
        d=google.com; s=arc-20160816;
        b=e9JDsJc09YIMpKVhiQS5b0G+eIidokw0LnON24iBQGWoFEJseSqVp4Jxe7d/u//34y
         yknkq9aXasF2J5LKIYHU3LXeyfE3i7axVWLp6mzkHfEI5afUWxRx+nWdf2DtpuhpPLUI
         BBBirWivUL6FV/MnmGfVH9yzqzhup2ppvwJVaRUWrZ1lt5kTW64mLZSwoyXaNcw1fxDc
         aZ7bnCU6KBbWvlQZXH5Z9RtpDquZzLNNNXXrg5pmRCemwNv7dMSHcEg7N5/pX+8Ydt1H
         RML0ggCn2m6Mk6jrgGDtRSQeBikbDhYmnHqYv46lScmGufpUY68T01nUkLZSa/fTQ+8+
         f1kA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=K8Zv8V52zsSx5OIu0AN8ygd1P9iRWZrB9jtIJM4wgqY=;
        b=aOr8GJX5qgWjQzVoChiA61h31l2J8sz4hnIbN/Ir6AOy3gZPECNL7+oiihIjDY5Xl7
         STHj4E3xzBwvs3jOE2zmqsGSJr9/GQFxROBp9WT7C5E16JN48Qc1rcb/GFri7FqpZiAK
         FucVVXN2QmJVjczgu4UC6ikwxeqIdRtguNAkufP3VU+uAk3jHYqbNwV/oTjTA1fp/Vms
         ATHitgHNZv3E4nqjGq6VYpny7QNMR6+ARmDIPkqwbyGoaN+IYcKPgL87vQQQHzYrgf9n
         WKBAlEhhcNYPBIZJmm22Q4KIui+uz+2QfRx35z6d+4CqBxLIHO2GwYHl3Npo56oAGbxC
         44Bw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id q6si222137pll.226.2019.06.12.10.14.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 10:14:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R281e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TU.ZihY_1560359634;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU.ZihY_1560359634)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 13 Jun 2019 01:13:57 +0800
Subject: Re: [PATCH 2/4] mm: thp: make deferred split shrinker memcg aware
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559887659-23121-3-git-send-email-yang.shi@linux.alibaba.com>
 <20190612024747.f5nsol7ntvubjckq@box>
 <ace52062-e6be-a3f2-7ef1-d8612f3a76f9@linux.alibaba.com>
 <20190612100906.xllp2bfgmadvbh2q@box>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <d2f6737c-6682-f985-0790-77483e95f298@linux.alibaba.com>
Date: Wed, 12 Jun 2019 10:13:51 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190612100906.xllp2bfgmadvbh2q@box>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/12/19 3:09 AM, Kirill A. Shutemov wrote:
> On Tue, Jun 11, 2019 at 10:06:36PM -0700, Yang Shi wrote:
>>
>> On 6/11/19 7:47 PM, Kirill A. Shutemov wrote:
>>> On Fri, Jun 07, 2019 at 02:07:37PM +0800, Yang Shi wrote:
>>>> +	/*
>>>> +	 * The THP may be not on LRU at this point, e.g. the old page of
>>>> +	 * NUMA migration.  And PageTransHuge is not enough to distinguish
>>>> +	 * with other compound page, e.g. skb, THP destructor is not used
>>>> +	 * anymore and will be removed, so the compound order sounds like
>>>> +	 * the only choice here.
>>>> +	 */
>>>> +	if (PageTransHuge(page) && compound_order(page) == HPAGE_PMD_ORDER) {
>>> What happens if the page is the same order as THP is not THP? Why removing
>> It may corrupt the deferred split queue since it is never added into the
>> list, but deleted here.
>>
>>> of destructor is required?
>> Due to the change to free_transhuge_page() (extracted deferred split queue
>> manipulation and moved before memcg uncharge since page->mem_cgroup is
>> needed), it just calls free_compound_page(). So, it sounds pointless to
>> still keep THP specific destructor.
>>
>> It looks there is not a good way to tell if the compound page is THP in
>> free_page path or not, we may keep the destructor just for this?
> Other option would be to move mem_cgroup_uncharge(page); from
> __page_cache_release() to destructors. Destructors will be able to
> call it as it fits.

Yes, it is an option. Since __page_cache_release() is called by 
__put_single_page() too, so mem_cgroup_uncharge() has to be called in 
both __put_single_page() and the desctructor (free_compound_page() which 
is called by both THP and other compound page except HugeTLB). But, it 
sounds acceptable IMHO.

>

