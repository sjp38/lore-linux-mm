Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1904FC07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 12:23:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C226820673
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 12:23:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C226820673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DE046B027E; Mon, 27 May 2019 08:23:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48E426B027F; Mon, 27 May 2019 08:23:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3580F6B0280; Mon, 27 May 2019 08:23:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBBC16B027E
	for <linux-mm@kvack.org>; Mon, 27 May 2019 08:23:36 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d15so27849815edm.7
        for <linux-mm@kvack.org>; Mon, 27 May 2019 05:23:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=rp/Ap/7Cj6hynWtQSOXxKX7uaC8ywFEL4vtIrA2RkNQ=;
        b=krsYQAH8bW4w3M5qVxQZ3A9W16VVqdZJcvYXs+tzTyeqRt673ycCxbkNfJWzYh/Tma
         V2fsATEtfBtI20X+e9WxuKcUvmiYM0eVBgEi7RsNq/QWJGUToQoqhdKGSniMbvrqn4IB
         xOazx1FbClr4Rf7JKwcSf2oAPnjr5BJBjkRKWPmFXWHxWpWDu58+du8+z4GRi61fMczm
         15M0H4CWxiF1Pl8cb/TQE3mkr0j96hNejGs5dTTnutFkAT9ybNy3t45HE/mbjbj+xlbO
         YtnDKvSgnFHC6i+pT2kLN7qefnaORTzEdcsjKyZZxJkJzBGwAZ4pxMv4zCfOrO/AbXEW
         qggw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVFi/1k6Avc20WNVlw/WuYY+0sgfEVjBtfVmVBKPUx6Wi101+Mo
	uHuV0Ng9+N5gc9G6xKVt/B1czeTvnIYK/faNnZlNSRvN9SrnPE5CeU60hf9kW6EBgyMDp9FZk0V
	KPGbTXazmbRg0EN0jkeuKDP4qSaVJCSKzm4Lihl03+hFgmnuzR6oPW0d6FePVzQjWkg==
X-Received: by 2002:a17:906:e28b:: with SMTP id gg11mr14105998ejb.306.1558959816470;
        Mon, 27 May 2019 05:23:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFaK+ZqFuCAz6lXmPv02t4prF/9Hy37S3Cvg9UrhcrQshweJpMTsE9tfDVXVP2239qCxZe
X-Received: by 2002:a17:906:e28b:: with SMTP id gg11mr14105911ejb.306.1558959815380;
        Mon, 27 May 2019 05:23:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558959815; cv=none;
        d=google.com; s=arc-20160816;
        b=ZjhreqajVcMWOrZh8z+18oKYA16eQ9s2OQkbrn8wSUWoFILsgwNeXBlvZgeDPeI/VC
         7uUF+uffJ1LUXa7PRRVpWjDH6BNMtjc2lIkvrGvp51QlcJATLgmjIqedsH/Jb1pEcyn2
         broKA/TOMj7LZ8pc65j+LG2M+U5WXKdD6CdwJVv4Z6UWCoyUg9X7oaHic3ghaA4ngzuu
         1rY2shY0U2qz0AAHFepXSkMH76PjvdMjnVMt1aE8ANvt4tW5dSjy0ZIxoz0/pbyQv1EN
         HqZeGOIAdPSZn3V6JEb6at3MWlxkZ3SQk0UGKrbstA6V7WyaVXDnnYkIHre9DsQg1zLg
         LeIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=rp/Ap/7Cj6hynWtQSOXxKX7uaC8ywFEL4vtIrA2RkNQ=;
        b=fO2zJs4C1mpjaexV+l4Fa6a9vR6bC/qUinuN/D1RsI2D0PjqsMWRvQ29UpQBBABEbT
         RVMA0JtmnDEE36aeSA6tz6A5UBsg/RZ6d8cgxjVp6QYNHAPEIlf8IqFcbNEP3LqOqxxb
         eNv+bgAksSJjlG3eVjRZKDuBUn37PprM5p3gmIDmv5f3h+8Z2SGvl4dcu3GdX01POKKn
         V7JzH1ImvTkV4cKQmpDkFzI7MKLuYHOLomnqvD66Znu9eMpnY0b19x6oJ0aQv+yhPnBa
         cdc3A3m6IvaWIQEYEffXzbaX98Rc9x1C3/xQGAVhBMdLPZ9wyyGqGQsKELsr/kuC7s2B
         CEQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y23si3885512eju.228.2019.05.27.05.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 05:23:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D79C5AF96;
	Mon, 27 May 2019 12:23:33 +0000 (UTC)
Subject: Re: [PATCH] mm/mempolicy: Fix an incorrect rebind node in
 mpol_rebind_nodemask
To: Andrew Morton <akpm@linux-foundation.org>,
 zhong jiang <zhongjiang@huawei.com>
Cc: osalvador@suse.de, khandual@linux.vnet.ibm.com, mhocko@suse.com,
 mgorman@techsingularity.net, aarcange@redhat.com, rcampbell@nvidia.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1558768043-23184-1-git-send-email-zhongjiang@huawei.com>
 <20190525112851.ee196bcbbc33bf9e0d869236@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <2ff829ea-1d74-9d4b-8501-e9c2ebdc36ef@suse.cz>
Date: Mon, 27 May 2019 14:23:31 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190525112851.ee196bcbbc33bf9e0d869236@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/25/19 8:28 PM, Andrew Morton wrote:
> (Cc Vlastimil)

Oh dear, 2 years and I forgot all the details about how this works.

> On Sat, 25 May 2019 15:07:23 +0800 zhong jiang <zhongjiang@huawei.com> wrote:
> 
>> We bind an different node to different vma, Unluckily,
>> it will bind different vma to same node by checking the /proc/pid/numa_maps.   
>> Commit 213980c0f23b ("mm, mempolicy: simplify rebinding mempolicies when updating cpusets")
>> has introduced the issue.  when we change memory policy by seting cpuset.mems,
>> A process will rebind the specified policy more than one times. 
>> if the cpuset_mems_allowed is not equal to user specified nodes. hence the issue will trigger.
>> Maybe result in the out of memory which allocating memory from same node.

I have a hard time understanding what the problem is. Could you please
write it as a (pseudo) reproducer? I.e. an example of the process/admin
mempolicy/cpuset actions that have some wrong observed results vs the
correct expected result.

>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -345,7 +345,7 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
>>  	else {
>>  		nodes_remap(tmp, pol->v.nodes,pol->w.cpuset_mems_allowed,
>>  								*nodes);
>> -		pol->w.cpuset_mems_allowed = tmp;
>> +		pol->w.cpuset_mems_allowed = *nodes;

Looks like a mechanical error on my side when removing the code for
step1+step2 rebinding. Before my commit there was

pol->w.cpuset_mems_allowed = step ? tmp : *nodes;

Since 'step' was removed and thus 0, I should have used *nodes indeed.
Thanks for catching that.

>>  	}
>>  
>>  	if (nodes_empty(tmp))
> 
> hm, I'm not surprised the code broke.  What the heck is going on in
> there?  It used to have a perfunctory comment, but Vlastimil deleted
> it.

Yeah the comment was specific for the case that was being removed.

> Could someone please propose a comment for the above code block
> explaining why we're doing what we do?

I'll have to relearn this first...

