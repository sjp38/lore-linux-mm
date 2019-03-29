Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CAD3C10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:54:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B1532183E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:54:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B1532183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BC7C6B000E; Fri, 29 Mar 2019 04:54:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 169FA6B0010; Fri, 29 Mar 2019 04:54:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0597E6B0266; Fri, 29 Mar 2019 04:54:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AD8206B000E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 04:54:43 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s27so733222eda.16
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 01:54:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=7tjkckpkllWMS1k+ooHJEg057LgZA3hUq4MRE7do7Sg=;
        b=MX4r0nBPxeVnfTGgzy7K94r5Y49/GWlFRHtPGqSnnWJNfAJbVB9H4wGJGpGNRDiyaQ
         geQG+fx8TyZlNWwV5V7F383Vk6OZyorp2Ia10ZUHMnJ8uK42LIT40/jjFvLwwqLbIOUQ
         56652vbZk6f91iJXqAanVVNk5uthU7jW4XC5Rq7GcVyGICbXo3vjuAvt41yqQz2DhA2o
         WNHNj4B2csVZKGRhiWsNYmkSE9pu9PeJ5Jv7nkSfPFqfmK1NUu0wovcQwHA+zESopspT
         Bt4qUFUulM7VlNIOF380FQWPy0AnjKSoVxj1QXQyXVaNPopORQ/uLJ+aPQbPu3TpWpln
         sjqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWr1bdhvLF4rPOp6Gvr/dIrBMhKOumtTZ8g4Fbns/uQKfsM7hBk
	f2UCvZTYKcNhVL3JNlKPHkJNvq0R3yWq4+C0WFqDV4sVkzhA2wm/hE3laM/KIF6pI7P+w4ICkE0
	RhzoyFZsMs9QwS/Wmv2kpe83r0kR0WAmp4mIUAZHoAIRxlW9an6XdcL9VW54KUfEBEQ==
X-Received: by 2002:aa7:d2ce:: with SMTP id k14mr24589020edr.195.1553849683277;
        Fri, 29 Mar 2019 01:54:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJ/F0IdDXIp2CV4D3ESu4jCuWSdIdxtKFEEzp35qV0HX/KwfxbjB0olJ7MSzu+oJsXe9++
X-Received: by 2002:aa7:d2ce:: with SMTP id k14mr24588994edr.195.1553849682672;
        Fri, 29 Mar 2019 01:54:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553849682; cv=none;
        d=google.com; s=arc-20160816;
        b=mzzgekujHR7dnQ0OV7d2phLYatmDXTxsvaPgCptPk/OKUH8p7EdU0N8Q9AaZejc6J/
         6W0lfydZoa6zYuWx4tnOODTjdge1Mj/Lga3NBAqelPkXKHqjN08Pc3emPWCHlkJShwjJ
         hp7Z6JxI7Ff90beE4EzGYrSPH/oEwd3H12phNzrXJoefPkHgCinXoEcIiQZ65nRdDdSZ
         WNAWqAPmv7+vlGYqT8tu7hgEAeeOvB2MvUN/fR48GS+JeCQFqkMNaeBjQ8RFUAB7TSMD
         jBcpXwu/zQiuhZzJaV9aM9WAL5sRWmUuwAxAWkfu7wBWo4DD+7DqCo6A+N4Jw4Gc60S9
         bgSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=7tjkckpkllWMS1k+ooHJEg057LgZA3hUq4MRE7do7Sg=;
        b=a8ijE1Yc85TNQvNBl5sTs7DsUjeiJnNnJuhJgvpBe0x5KuEags7jqTM3xtrP1aMSq3
         q5lrNXu1u7O8eTdv8uBpQA5CMNGA7h4ELfoJ8Z4tETq8EAxhTsy5uCOeuQrCH5pycH3z
         G3tHdNkPoeH0K19LbP5sW3+c76d5xgxvk8XCd8f+we1DBLHZprlIuVQos3tpoKERc5iM
         q+I0fLGwuY/xSRN9x+GO40832FtbQ7FO2Oi4NT8QFmujg8ddUMd1j6fchWmyoU4qyK5a
         rF9kAfXdGJS8iPmRIrNLgKMVmL2uxE9aJC+1AwOiHNW0FsvooK/smsk/bTzis0u5P8t1
         JkIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n14si82030edd.269.2019.03.29.01.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 01:54:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3B998AE3F;
	Fri, 29 Mar 2019 08:54:42 +0000 (UTC)
Subject: Re: [PATCH] mm/compaction: fix missed direct_compaction setting for
 non-direct compaction
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, mgorman@techsingularity.net,
 Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
 shaoyafang@didiglobal.com
References: <1553848599-6124-1-git-send-email-laoar.shao@gmail.com>
 <60f6a5fd-e4d3-b615-6f41-cc7dd16d183c@suse.cz>
 <CALOAHbC7PqQ7UMm5Az=BAz9_hppYMWgNvxhq7EhqOkX0rWuQCA@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <e328008c-7a05-5d0e-77d7-363d21a045ed@suse.cz>
Date: Fri, 29 Mar 2019 09:54:41 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <CALOAHbC7PqQ7UMm5Az=BAz9_hppYMWgNvxhq7EhqOkX0rWuQCA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/29/19 9:48 AM, Yafang Shao wrote:
> On Fri, Mar 29, 2019 at 4:45 PM Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>> On 3/29/19 9:36 AM, Yafang Shao wrote:
>>> direct_compaction is not initialized for kcompactd or manually triggered
>>> compaction (via /proc or /sys).
>>
>> It doesn't need to, this style of initialization does guarantee that any
>> field not explicitly mentioned is initialized to 0/NULL/false... and
>> this pattern is used all over the kernel.
>>
> 
> Hmm.
> You mean the gcc will set the local variable to 0 ?

Not local variable, but fields omitted in this "designated initializers"
scenario.

> Are there any reference to this behavior ?

https://gcc.gnu.org/onlinedocs/gcc/Designated-Inits.html

"Omitted fields are implicitly initialized the same as for objects that
have static storage duration. "
and static objects are implicitly 0

