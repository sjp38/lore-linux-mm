Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C6F2C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 17:54:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74D7D206A3
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 17:54:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74D7D206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 046456B0003; Mon,  1 Jul 2019 13:54:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F38658E0007; Mon,  1 Jul 2019 13:54:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E008B8E0002; Mon,  1 Jul 2019 13:54:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f77.google.com (mail-ed1-f77.google.com [209.85.208.77])
	by kanga.kvack.org (Postfix) with ESMTP id 937C66B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 13:54:51 -0400 (EDT)
Received: by mail-ed1-f77.google.com with SMTP id f19so17471232edv.16
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 10:54:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AkKTFIrBL8Snd5L9+VQ6h4NpauRkIHe61oLcvgvVcTw=;
        b=GGPUdrb8+692bkR3I/JfdBz/3M4NNWqQ4swZduTUdF4k5GKU4F+a6BEUkVrm/KH+1F
         yIGr5zfbSnnoFN3rWvAJ0FK7GSRtIlruQwFkjmNIJhDEO3dTp2IQlaPomcAaQ+2Oo5zC
         B8OcJ/0tOylYboqCm0zlnnW37aUGydBhTOZ79YxMKzudK98M6whd+k4N3NBHVhazsD4l
         jHg9KloUHd9jHZ5StrniL0WPCwHertfpZY5rCtFv4rCZ1+O06CA0Y3hsREg4c7AOixox
         dTMVIBKnl39vkphFmKztODcQnVarn/83troZzqNLpLirlRliw3zYPry6ziX8Bf+AFEB7
         GZDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAXXAh2Y4g12gjKvkovM+Y3Z1QwkSD/sYraiegG1yjEMWgCwXtr9
	FrTwdr8R+7Brxb6Daedo7Y19Vs9ut/b3DjBaxDHBkDnoVdR3uWrf4lwwWIH0V+CxT/eVlFnHSoa
	nQfM9vLHpvVU5kAzT9R+xBApltrVlK+TQnfEKvsK1xQcrpFJmCtYXM6Mx3W5nFFRbGw==
X-Received: by 2002:a17:906:9609:: with SMTP id s9mr20789600ejx.233.1562003691164;
        Mon, 01 Jul 2019 10:54:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjX4S6EnlG2yrehTxnKVG99nVWhceqEP9kLmvOtUeJMA9lf636N2zRYvCssbU6q6gm8tL4
X-Received: by 2002:a17:906:9609:: with SMTP id s9mr20789554ejx.233.1562003690388;
        Mon, 01 Jul 2019 10:54:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562003690; cv=none;
        d=google.com; s=arc-20160816;
        b=WJk7C9FZHRuYhihLuSHLsp465z3Wr3sM62VL1c0IQ8yz9xeEvJ3H6ubfa8exY1/yS+
         IlrFDC60N4tCJyVE4oKBxTPGetlxlCGESW3ODyd9NEkx7V7V6MO2qL18GZgN2w0sjpPO
         7s64KvyexznLkRtf1mQD5aBfo/lXJO7uLxaj06aDzrwCTVyv14r3eg0x+WaJSkHnvloo
         msaYewqHxPahXiFHREO1u3LY/pLHgyYgkkgg6KfcSQ1iFImV/y38O3pm0TkA2TZq8iqJ
         lLNMw/M8sYWahi/a/zrC27J6XPnKG02a6gXTv7JnYPtYOwfMt70xJjicu7uzOpyXM51T
         Su7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=AkKTFIrBL8Snd5L9+VQ6h4NpauRkIHe61oLcvgvVcTw=;
        b=R5i/MU0rcBiPZ9pHtI/Xzlg54QDA3hC2fZ3BrpWif/8RV4k/WCocrugpN2YrYtQoIB
         3lCE1H2yBhp3NW4EhwuEqZIBgqT++jiBpCiC70DcvkbkX7OI07x4cW8RuNh3FKmEnwtz
         xnxZJxWKHOmbWOnJlPQaEOi7Kcb4pIwDUrDES60+/tHfSYkvYUrr9QzJruxuWVMhDRXf
         kNYnntYXe93zFaYcr4ELjDFg4/ChCmqUDoIPueubU8zSxjNQv6h4dvKMQO0n+xDYB3Mw
         4t+k5o2ZJLFS3sCV/LeIT3l7vwvUpIqe5V22hMotqk1lFRA3E9ABE4Q2fVHfgbaxtFUR
         Ko+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l2si7678595ejr.264.2019.07.01.10.54.50
        for <linux-mm@kvack.org>;
        Mon, 01 Jul 2019 10:54:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7331228;
	Mon,  1 Jul 2019 10:54:49 -0700 (PDT)
Received: from [10.1.197.57] (e110467-lin.cambridge.arm.com [10.1.197.57])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 890D63F703;
	Mon,  1 Jul 2019 10:54:48 -0700 (PDT)
Subject: Re: DMA-API attr - DMA_ATTR_NO_KERNEL_MAPPING
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org,
 iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
References: <CACDBo564RoWpi8y2pOxoddnn0s3f3sA-fmNxpiXuxebV5TFBJA@mail.gmail.com>
 <CACDBo55GfomD4yAJ1qaOvdm8EQaD-28=etsRHb39goh+5VAeqw@mail.gmail.com>
 <20190626175131.GA17250@infradead.org>
 <CACDBo56fNVxVyNEGtKM+2R0X7DyZrrHMQr6Yw4NwJ6USjD5Png@mail.gmail.com>
 <c9fe4253-5698-a226-c643-32a21df8520a@arm.com>
 <CACDBo57CcYQmNrsTdMbax27nbLyeMQu4kfKZOzNczNcnde9g3Q@mail.gmail.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <0725b9aa-0523-daef-b4ff-7e2dd910cf3c@arm.com>
Date: Mon, 1 Jul 2019 18:54:47 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CACDBo57CcYQmNrsTdMbax27nbLyeMQu4kfKZOzNczNcnde9g3Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/07/2019 18:47, Pankaj Suryawanshi wrote:
>> If you want a kernel mapping, *don't* explicitly request not to have a
>> kernel mapping in the first place. It's that simple.
>>
> 
> Do you mean do not use dma-api ? because if i used dma-api it will give you
> mapped virtual address.
> or i have to use directly cma_alloc() in my driver. // if i used this
> approach i need to reserved more vmalloc area.

No, I mean just call dma_alloc_attrs() normally *without* adding the 
DMA_ATTR_NO_KERNEL_MAPPING flag. That flag means "I never ever want to 
make CPU accesses to this buffer from the kernel" - that is clearly not 
the case for your code, so it is utterly nonsensical to still pass the 
flag but try to hack around it later.

Robin.

