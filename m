Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 527E7C49ED6
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:30:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11C85218AF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:30:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=rasmusvillemoes.dk header.i=@rasmusvillemoes.dk header.b="T/zoUw8t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11C85218AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rasmusvillemoes.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF3826B0273; Mon,  9 Sep 2019 14:30:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA49F6B0276; Mon,  9 Sep 2019 14:30:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 992B56B0277; Mon,  9 Sep 2019 14:30:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0192.hostedemail.com [216.40.44.192])
	by kanga.kvack.org (Postfix) with ESMTP id 72FE86B0273
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:30:10 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0D6E1181AC9AE
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:30:10 +0000 (UTC)
X-FDA: 75916221780.21.trail35_75c62e2afd545
X-HE-Tag: trail35_75c62e2afd545
X-Filterd-Recvd-Size: 4311
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com [209.85.208.65])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:30:09 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id a23so11625726edv.5
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 11:30:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=rasmusvillemoes.dk; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=8M5+TPDS2IjP0aWDzyGkaBopFbLj6s+vVoGtuuyUqNo=;
        b=T/zoUw8tKc5M592mbqf3dI8cKV6ZOgavo+bW0sf82wiwxeahnejH1Es2N3YHzwsLY5
         dRjX3VlE7qiQHjwM1RVgwqjkbBRSjznlm2/6IBrVp1xlPxIYGTD1jq4bIQO2KVFBvuHb
         +ez3hiQngmBc6xO9JynEjvOo0o8cGsYmfrES4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=8M5+TPDS2IjP0aWDzyGkaBopFbLj6s+vVoGtuuyUqNo=;
        b=btDzFS5IzkUyIKjg9kJGhl60e1zPXLsXUylSRFscXSUTC6i8NQasePkgrCiVfFDs1n
         vSBGOXWVVHqEl0Jt0wYVhnsDPL88UODyfr3desDXN7G8Ls7oQ/AffrVTXqAvbxutBllQ
         RngTQ1oITqq08xenrFFiiZwkHxUWgosOTf1SacHr6ajr6e3Vk96N4xSfNCVirORUbbb/
         CEO261EE9SiOSL6xLI3YnrycGlpOOsMVm+LvTF/AY8JO96ZMgI7ie9iYTRJY0agRmGjc
         c6jwilFZAASPPaegvBcbOgBnH0gT792W+v5hTYqv68SGsciY7VVgCEKcva4s1V4jdTQp
         X8zQ==
X-Gm-Message-State: APjAAAVJCQQQsU/1btWCVcx53lxYDt09Yu7gleDKn6JRhGMmIYnTVrwl
	iQR/LHbg+sRIOxvvkL3xdF+WEw==
X-Google-Smtp-Source: APXvYqzD8IHDXeozNxyelzcX+YHu6/LinTuuQDxQv3DDjTdPQp1mAn8uFEh/89nYDke9qQaJASBpdA==
X-Received: by 2002:a17:906:bcc9:: with SMTP id lw9mr20786884ejb.161.1568053807693;
        Mon, 09 Sep 2019 11:30:07 -0700 (PDT)
Received: from [192.168.1.149] (ip-5-186-115-35.cgn.fibianet.dk. [5.186.115.35])
        by smtp.gmail.com with ESMTPSA id g20sm520589ejs.15.2019.09.09.11.30.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Sep 2019 11:30:07 -0700 (PDT)
Subject: Re: [PATCH 1/5] mm, slab: Make kmalloc_info[] contain all types of
 names
To: Pengfei Li <lpf.vector@gmail.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Christopher Lameter <cl@linux.com>, penberg@kernel.org, rientjes@google.com,
 iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190903160430.1368-1-lpf.vector@gmail.com>
 <20190903160430.1368-2-lpf.vector@gmail.com>
 <4e9a237f-2370-0f55-34d2-1fbb9334bf88@suse.cz>
 <CAD7_sbEwwqp_ONzYxPQfBDORH4g2Du=LKt=eWf+6SsLgtysBmA@mail.gmail.com>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <3a95d20d-ccf9-bd45-2db3-380cc3e0cd17@rasmusvillemoes.dk>
Date: Mon, 9 Sep 2019 20:30:06 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <CAD7_sbEwwqp_ONzYxPQfBDORH4g2Du=LKt=eWf+6SsLgtysBmA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/09/2019 18.53, Pengfei Li wrote:
> On Mon, Sep 9, 2019 at 10:59 PM Vlastimil Babka <vbabka@suse.cz> wrote:

>>>   /*
>>>    * kmalloc_info[] is to make slub_debug=,kmalloc-xx option work at boot time.
>>>    * kmalloc_index() supports up to 2^26=64MB, so the final entry of the table is
>>>    * kmalloc-67108864.
>>>    */
>>>   const struct kmalloc_info_struct kmalloc_info[] __initconst = {
>>
>> BTW should it really be an __initconst, when references to the names
>> keep on living in kmem_cache structs? Isn't this for data that's
>> discarded after init?
> 
> You are right, I will remove __initconst in v2.

No, __initconst is correct, and should be kept. The string literals
which the .name pointers point to live in .rodata, and we're copying the
values of these .name pointers. Nothing refers to something inside
kmalloc_info[] after init. (It would be a whole different matter if
struct kmalloc_info_struct consisted of { char name[NN]; unsigned int
size; }).

Rasmus

