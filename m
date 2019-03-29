Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEDC4C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:11:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78BF02173C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:11:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="TCCYngfr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78BF02173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A2EC6B0007; Thu, 28 Mar 2019 22:11:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 052226B0008; Thu, 28 Mar 2019 22:11:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E35E26B000C; Thu, 28 Mar 2019 22:11:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDC46B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 22:11:19 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id m37so588872plg.22
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:11:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=kNXxnRe3M1ijRkP4yynTmx6uLTiKcabSICyOQfMgSMw=;
        b=FHMSDus5YtYB8IUK3tYxzFhvWY2wm/u3EclqoXeDM+ipFhZ8WXiJMRofczTBlvk20c
         XtGA12sdLrygdvj/qXln1xoOh+FuX+C5+qzz1dt0fx/NyH/QslydyDytL5Wx4Qi5AgI5
         IeUuDxpSrIIxkpRJDsk9ChdvPoOTuuTw6QxI0U69quZI25XwEdBXkrMXZ73X1tbi98Oj
         nGy0WtuO+7mqallyM4uN7dL5W4Km1mt92fOo+6TcKl5ynwcoTzHwzfEmaK/w7Bzunf+j
         bye52COmkOiZHY5p4B+JAh5iS+2H02Y4RxNcz7061PDimQy641CfHB07BIt4yx4Kq+3/
         XpmA==
X-Gm-Message-State: APjAAAU8zhZH1H3TjadO+aXD1Ynztgt6tOKOrQwP7+RmI2IoT/IG+nxU
	y+SpTTBHGy+wysLo9Xnaiokl4VU7NwPfrEHtH9xPtuqO9dnxri12i+FzMApw0nPcUXaEzIFlKEb
	j8j6U4/O+JEagp2G+uRU0TmQDl7OXNqjhUGbocyJS9UpKmobyNsjVfLnliuDEE2HnRQ==
X-Received: by 2002:a17:902:b58f:: with SMTP id a15mr31975900pls.36.1553825479251;
        Thu, 28 Mar 2019 19:11:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjAdVKQlp+r55pUk4twRRNAGBHcQZjC20+TA8kP+IWj+63ZYWhwD162Z+xVdzLeSYoUBfD
X-Received: by 2002:a17:902:b58f:: with SMTP id a15mr31975858pls.36.1553825478507;
        Thu, 28 Mar 2019 19:11:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553825478; cv=none;
        d=google.com; s=arc-20160816;
        b=d8I4qhGAsWLcExDyxc9al0EQUs4zOYRxZaTWJJFvXreNGYKnO/Ooz0W8gCVuzJi17q
         DfhRAlgcvd5vUZX1PkMQ7hN47AgZVkhk9FsOMMjpfBZ/d2wDCuUZq5LyUVm7JgJQ/QIr
         KAWc0jKjIInBMTnSa5YZ5ty30apAsRB2KO98AFzo7tipU+177/21aghfM/Xvw4YBt8oC
         UeztruaWg8qr2wHgnDbvRfVZkRUZAq05//kelHgLlCrUU7Rb1QLSLfMj1OkPHuKRZ8bm
         U5L1Qhsih861e4lLASTBE3IhSasCFcU0WohfaLTLLOGdjaV05SOzrq7f/ZTgXkuzs8OV
         cOsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=kNXxnRe3M1ijRkP4yynTmx6uLTiKcabSICyOQfMgSMw=;
        b=A1RM2AY8BUdTtavM2lnVeHR3EYaeHiyN8N7Zz7F8KQBmkE2DtstuA54AWMEZSt+V7c
         gZ9jkFphRsAy8MQa4V9dirfD0ZsXDBjZT11jsbIdTnRnlKXi8UMwP3QEfdXVhcl+nnUV
         AyZPW/j8bMkxMc+9wtmkutz9gy5FUyKa/Knip48Cewtc4jzasI+AUWpsM/bCII/p3X5U
         /UTs+RARBNabe0FrdYzRtU4t2oho/z/d0/xutSlgJABThMf8FGKyT0quCXp7EJLwysuQ
         ssh98c0or2oHqmLi4r8lLjtXowKT5kii6vmi3ji18LB3TDCFiJT3kgc0fdlxodn+tzlh
         u9vg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TCCYngfr;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id f63si677354pfa.154.2019.03.28.19.11.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 19:11:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TCCYngfr;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d7ec40001>; Thu, 28 Mar 2019 19:11:16 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 19:11:17 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Mar 2019 19:11:17 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 29 Mar
 2019 02:11:17 +0000
Subject: Re: [PATCH v2 02/11] mm/hmm: use reference counting for HMM struct v2
To: Jerome Glisse <jglisse@redhat.com>
CC: Ira Weiny <ira.weiny@intel.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-3-jglisse@redhat.com>
 <20190328110719.GA31324@iweiny-DESK2.sc.intel.com>
 <20190328191122.GA5740@redhat.com>
 <c8fd897f-b9d3-a77b-9898-78e20221ba44@nvidia.com>
 <20190328212145.GA13560@redhat.com>
 <fcb7be01-38c1-ed1f-70a0-d03dc9260473@nvidia.com>
 <20190328165708.GH31324@iweiny-DESK2.sc.intel.com>
 <20190329010059.GB16680@redhat.com>
 <55dd8607-c91b-12ab-e6d7-adfe6d9cb5e2@nvidia.com>
 <20190329015003.GE16680@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <cc587c80-34ea-8d08-533d-0dc0c2fb079f@nvidia.com>
Date: Thu, 28 Mar 2019 19:11:17 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190329015003.GE16680@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553825476; bh=kNXxnRe3M1ijRkP4yynTmx6uLTiKcabSICyOQfMgSMw=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=TCCYngfrlCQTvKv1rhpyIVK3LxaWz+hW7XDu8Fzz9E/d18QO1CqEZSqLswtry/e+k
	 UrOnp6rld7LJCk+y6FB6xYN1orUNpKBjpF7gxkWh15FE/QSc2Ls6HIK6gOG6T8QHhH
	 zVDoPrYKUbDfwd3pbHLSCYLtDOdb/ZMVJNIiiEzgooV072BV415VSMJ+gPjf/MAyxX
	 FjKg1oym70nUDnOGY/vhLbTP1dhy6HTBWdb5F738n1Hud5sL50J7LDGCz2NfcCGsPR
	 vwOrkHl/E8o01yxW4w9XdyfDc8dtAZM08lyhbdMr9jwsV97Ot8Dp0Fp0ZlEuZFD7w9
	 vkAvK9PA2IttA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 6:50 PM, Jerome Glisse wrote:
[...]
>>>
>>> The hmm_put() is just releasing the reference on the hmm struct.
>>>
>>> Here i feel i am getting contradicting requirement from different people.
>>> I don't think there is a way to please everyone here.
>>>
>>
>> That's not a true conflict: you're comparing your actual implementation
>> to Ira's request, rather than comparing my request to Ira's request.
>>
>> I think there's a way forward. Ira and I are actually both asking for the
>> same thing:
>>
>> a) clear, concise get/put routines
>>
>> b) avoiding odd side effects in functions that have one name, but do
>> additional surprising things.
> 
> Please show me code because i do not see any other way to do it then
> how i did.
> 

Sure, I'll take a run at it. I've driven you crazy enough with the naming 
today, it's time to back it up with actual code. :)

I hope this is not one of those "we must also change Nouveau in N+M steps" 
situations, though. I'm starting to despair about reviewing code that
basically can't be changed...

thanks,
-- 
John Hubbard
NVIDIA

