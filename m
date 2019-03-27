Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C4A0C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 13:05:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3875821734
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 13:05:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="OMdCtJAO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3875821734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBBC16B0010; Wed, 27 Mar 2019 09:05:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6BB46B0266; Wed, 27 Mar 2019 09:05:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E53C6B0269; Wed, 27 Mar 2019 09:05:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC3B6B0010
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 09:05:35 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id m8so14474435qka.10
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 06:05:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=d8vohrDHmXaj8dPeFxTgq9hFa6mnamq9JQBWUjd1a/E=;
        b=raXrblCLKKm9mwyyVa6woFPH1RIosoMtVTd3V8U4OU5MUY+rtrjXjZ6IGEtHMZKli+
         lfsf0giAG4dJsF58C4jIM8ZeGsgYX6uP2oqmjDJsObq2iskDIDpDzLvFlPgpMs8i7fr3
         W7vSA1XrY3bmmDYWXjjZUDJAQtCW3wR9YtR4C6iNYA5Du2Td/5a+6kYTtrnmbZfm9dDW
         sqKb6nPDGGxgmvv2ZIzWBio9qVvcsCnatm//sm3GA2cZ6s8YS6RbQFpJPNAupWfgjuoo
         BzC8rhdcre2UVaRU+GM8V/uUovYFBzTuhlDRaXrd3ebjVnwOy+4IlJr4xPqkgRDmjthz
         bRww==
X-Gm-Message-State: APjAAAUSgJuXT+QDQ7+pKXrfw1EYB9wKv8B6a+k9qI1FyZGS5nnmuQPD
	MtyHlcnQ2mJfwCMFRUtxD4JMwxuUH9CbSISZk/q+rPKCA+rlZ7aaVpeeDtieoxJpsQ62/1MWTtk
	Ko9wn08Zg6ZbOfzup6yYvAoKkCrNyY4jWMgEj2qurFnV87+OEx8X8c/wRCgzWs5jRww==
X-Received: by 2002:a37:a412:: with SMTP id n18mr27269032qke.321.1553691935252;
        Wed, 27 Mar 2019 06:05:35 -0700 (PDT)
X-Received: by 2002:a37:a412:: with SMTP id n18mr27268962qke.321.1553691934541;
        Wed, 27 Mar 2019 06:05:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553691934; cv=none;
        d=google.com; s=arc-20160816;
        b=q3sRz2/3aUe51x/Ykpct4pFJg2tCBGSzlUe6yvFaocggB64KSazBezPqkdUXaL2Ki8
         IdY1lTQ03pW1g+UUDqF1bhvx8C11vqpVN0EWYf+mzR3l5VK/Ybv90P9drGD9aV5elauK
         Jf0fOG/EP4zg2rx7sib+QOjtqQAeo+GhrZZR/RelUU1nY/v414bxo8ggzuRuxvF2jIDW
         KGj1QivG3XFlJBQ+/hGECnh2t02KYvVHcwS5mXB8zwY7yacfribtNA3njpM5a0n6Z2RL
         fiAf1zUsaROOt5+M977BXIXsbjOYOfE2pk57Tf+Rnl/flR4Li4cV4+kfFmQw9Excl0xN
         UDPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=d8vohrDHmXaj8dPeFxTgq9hFa6mnamq9JQBWUjd1a/E=;
        b=QNpD38axalg5vhCqsoNSFhbBWWSQS5jU1Ku5/fJ3guA+i1HKKrPCBJDW+Akl67ZwdU
         KYFBfoYCaNA3emyiSyadQblsgvZtSO9d8ehbjorF0SgSq4abMGGDMNzcxi18Po3Ljv/J
         ztcgFw4MTzkhPtdWyNq6XpzWvt9FlaABP4hpwI1MGo/05PdGMnVuK8PUKHhrRlgACwg2
         A1WKBsApzZBpxp8yAB5Sc7QNv1VAcKm4q9JIfIveb0e0/E5h3ysNBGhqFcp06oVPNlok
         EClDqJdKesix3yJefwW90Za2QmzRTBk/Sdmb26XFkn54v/1j6HJqxTZWTpOblK9EnliY
         nnXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=OMdCtJAO;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o56sor1787384qvc.71.2019.03.27.06.05.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Mar 2019 06:05:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=OMdCtJAO;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=d8vohrDHmXaj8dPeFxTgq9hFa6mnamq9JQBWUjd1a/E=;
        b=OMdCtJAOXebwBZD85kjEwulAskD+huji+vaYW52nRq+9CBDXpY53JyqfSKEi7EmIWT
         yvDGt42qPNSv3hSlnuL4syyy3ntEKa0rZYusPb5qDvK+diGG8aS3W5HuTM+5k2PCfw36
         EajfVK64CbZzIqq0rugOlQatseZOB5P9cY5zfVpR+1qjdzOqtBfoO8DpbJAYct7QpPkB
         c1uNEXhRqr8tJjIepFBjyezk9bL5v33YRovDkB0n8OjWzQgQmb2daPFy7JGGMpYWb6+H
         yrNRJvHoy7oT94KfCnURKxnhyIkOItKtbGsesRdWd5gZcPjFyGTyJvVY2LFgWnYhSiq2
         Hrlg==
X-Google-Smtp-Source: APXvYqyowtPb8iUVv0sqpgQw1DZfVAzV8hh9EtnJ9RGb27LO1hsBlIuqOKgOexg0m3zetsNP9fd+zA==
X-Received: by 2002:a0c:8693:: with SMTP id 19mr30981574qvf.73.1553691934222;
        Wed, 27 Mar 2019 06:05:34 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id z20sm5101396qkb.52.2019.03.27.06.05.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 06:05:33 -0700 (PDT)
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, cl@linux.com,
 willy@infradead.org, penberg@kernel.org, rientjes@google.com,
 iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190327005948.24263-1-cai@lca.pw>
 <20190327084432.GA11927@dhcp22.suse.cz>
 <651bd879-c8c0-b162-fee7-1e523904b14e@lca.pw>
 <20190327114458.GF11927@dhcp22.suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <68cff59d-2b0e-5a7b-bca9-36784522059b@lca.pw>
Date: Wed, 27 Mar 2019 09:05:31 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190327114458.GF11927@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/27/19 7:44 AM, Michal Hocko wrote> What? Normal spin lock implementation
doesn't disable interrupts. So
> either I misunderstand what you are saying or you seem to be confused.
> the thing is that in_atomic relies on preempt_count to work properly and
> if you have CONFIG_PREEMPT_COUNT=n then you simply never know whether
> preemption is disabled so you do not know that a spin_lock is held.
> irqs_disabled on the other hand checks whether arch specific flag for
> IRQs handling is set (or cleared). So you would only catch irq safe spin
> locks with the above check.

Exactly, because kmemleak_alloc() is only called in a few call sites, slab
allocation, neigh_hash_alloc(), alloc_page_ext(), sg_kmalloc(),
early_amd_iommu_init() and blk_mq_alloc_rqs(), my review does not yield any of
those holding irq unsafe spinlocks.

Could future code changes suddenly call kmemleak_alloc() with a irq unsafe
spinlock held? Always possible, but it is unlikely to happen. I could put some
comments on kmemleak_alloc() about this though.

