Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15841C3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 16:15:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C93CD2342C
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 16:15:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Vydb4Dle"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C93CD2342C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 688BA6B000A; Fri, 30 Aug 2019 12:15:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 662296B000C; Fri, 30 Aug 2019 12:15:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54F696B000D; Fri, 30 Aug 2019 12:15:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0161.hostedemail.com [216.40.44.161])
	by kanga.kvack.org (Postfix) with ESMTP id 30C826B000A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:15:26 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B7ADD20EEC
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 16:15:25 +0000 (UTC)
X-FDA: 75879594210.26.head12_698cfffeac510
X-HE-Tag: head12_698cfffeac510
X-Filterd-Recvd-Size: 5121
Received: from mail-wm1-f68.google.com (mail-wm1-f68.google.com [209.85.128.68])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 16:15:25 +0000 (UTC)
Received: by mail-wm1-f68.google.com with SMTP id v15so7972282wml.0
        for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:15:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=RvULTbglvsEpSUEl2PMG0UwvBIgjs3k2jzK9oMeOf/g=;
        b=Vydb4Dle1to+M1trUotpf7b+sETb6evWQuAc+mqP6Se10ww7Uj5Z2OJh4a8WeQKK4H
         JcelOy8LVyJLrAbl57+7h7YSZwdGEUW62VBWmClF2upOMUUN3h3BNuXNF4FrHNOlBCXo
         uZASVSphcFVKqsCYib4AhC+ffQNc6MqSbc8ktNejdbKsj9mZMpaTSwlfkfKWjDH/A9Uz
         EsbQF8GGUnD5U3KS+q/BQGAyagegoMcvkELq9KT+kIorskpg8butTUZMU0cT6wkmOObY
         VSFnKRNz9DXKENkvJeVh/8+KPTJcJ5ORccvuKcueZ3sjeLF0Igst+bup83+efeb5zDGZ
         07Jw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=RvULTbglvsEpSUEl2PMG0UwvBIgjs3k2jzK9oMeOf/g=;
        b=OHznpjn66Js5pG7EnLKYwlLmI4uATcUd3QnUgl5P/iwfdiL3YSOD3bmnsRkh8euHTb
         ISzLHDKZuGnjgxQ4PRsGkVGNdU7IwSIYZXHs9YvoZRu07+h9tylPv91fBLOIzRMgpO3L
         L5cMx8MRjj5fTuRjApnvUVWxE/kou9HhmGQQGZ3nrppihlOiqW4af4NdphkFSannwpOt
         Tse9iykFIIS3nPTBnIkHg31LYckNfDFQf5aEly11Tws0WQzckX33QTasCZOSLNtIcwmX
         0ePqw6eX3nsuo25pdArEkBoUWldnQ7pAXi5OdxVPETmJIu6rJLKSKIHbzHwyw5BNoxHT
         srgg==
X-Gm-Message-State: APjAAAUy9PA13K90Pr5znn7UmKsdYW5ff5zwku0tKKenK8Cu937JY67F
	kdSuYSjm1RgVo7/jjVoH8A8=
X-Google-Smtp-Source: APXvYqwRC7VjVdR0nKtT76M4w3gVjPwIDRv5e5ONZ1A8loK1XrViNO6i2f2wuGBdd7VkCTp3RNgyew==
X-Received: by 2002:a7b:c954:: with SMTP id i20mr16685029wml.169.1567181724174;
        Fri, 30 Aug 2019 09:15:24 -0700 (PDT)
Received: from [192.168.8.147] (95.168.185.81.rev.sfr.net. [81.185.168.95])
        by smtp.gmail.com with ESMTPSA id f6sm15241274wrh.30.2019.08.30.09.15.23
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 30 Aug 2019 09:15:23 -0700 (PDT)
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
To: Qian Cai <cai@lca.pw>, Eric Dumazet <eric.dumazet@gmail.com>,
 davem@davemloft.net
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1567177025-11016-1-git-send-email-cai@lca.pw>
 <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
 <1567178728.5576.32.camel@lca.pw>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
Date: Fri, 30 Aug 2019 18:15:22 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1567178728.5576.32.camel@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000022, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/30/19 5:25 PM, Qian Cai wrote:
> On Fri, 2019-08-30 at 17:11 +0200, Eric Dumazet wrote:
>>
>> On 8/30/19 4:57 PM, Qian Cai wrote:
>>> When running heavy memory pressure workloads, the system is throwing
>>> endless warnings below due to the allocation could fail from
>>> __build_skb(), and the volume of this call could be huge which may
>>> generate a lot of serial console output and cosumes all CPUs as
>>> warn_alloc() could be expensive by calling dump_stack() and then
>>> show_mem().
>>>
>>> Fix it by silencing the warning in this call site. Also, it seems
>>> unnecessary to even print a warning at all if the allocation failed in
>>> __build_skb(), as it may just retransmit the packet and retry.
>>>
>>
>> Same patches are showing up there and there from time to time.
>>
>> Why is this particular spot interesting, against all others not adding
>> __GFP_NOWARN ?
>>
>> Are we going to have hundred of patches adding __GFP_NOWARN at various points,
>> or should we get something generic to not flood the syslog in case of memory
>> pressure ?
>>
> 
> From my testing which uses LTP oom* tests. There are only 3 places need to be
> patched. The other two are in IOMMU code for both Intel and AMD. The place is
> particular interesting because it could cause the system with floating serial
> console output for days without making progress in OOM. I suppose it ends up in
> a looping condition that warn_alloc() would end up generating more calls into
> __build_skb() via ksoftirqd.
> 

Yes, but what about other tests done by other people ?

You do not really answer my last question, which was really the point I tried
to make.

If there is a risk of flooding the syslog, we should fix this generically
in mm layer, not adding hundred of __GFP_NOWARN all over the places.

Maybe just make __GFP_NOWARN the default, I dunno.

