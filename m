Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5283DC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:24:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04A04222BB
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:24:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Mx4KDzcP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04A04222BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 850138E0004; Tue, 12 Feb 2019 13:24:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 800078E0001; Tue, 12 Feb 2019 13:24:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EF0B8E0004; Tue, 12 Feb 2019 13:24:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2098E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:24:11 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f125so2642696pgc.20
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:24:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=hCH7rykdmFoLvlo08xt1NV75vMDVG4DoRrkvFI4IOE8=;
        b=U/7wu8OoC99C4ZKQP1/b2uwdZhrgpYNY+LgSfty0yZCmvK5XESLsO9lRDUhIn4GWah
         j09lVEh5wETF+bMdc391d+T1VyybnV29NOkm/qcDdaL7jOQw0QXbwUAQ7KYNcarEOAU5
         pl+1SipSmvRSittvO7yAwrKphJkDPeNVjyusYFsQdKHJNAutECtPBsAPQWPYaLXKaujv
         DkYY9QChZlkikB9JP7b6k7QQbAOx1pU4L4zW3ldLDR0OUXXVXvv2EQBsK//TiImRkefe
         mUU5KNz/nSNlPi6encrgPJGkaeC+2Ek8a3O8qJgbdkj9NmFDgq5rFIgIaqnMbhMijBXR
         LRqQ==
X-Gm-Message-State: AHQUAuZjqiMcQ5ONwjpFqVwDkUkizYeho06d2ukL6FYv2YNUrt6QQOFh
	AUM2D3clqe1bbbqYjP6JsWpegx11g4pfKB/g8mf75ImcpEB5eRQgzFdhxONpqeg1zPRI9DgyNJm
	WBbydW0aS1omj8NL6BeHDAiB28Oc1xMCsJLkNKYXx8bbr4udnQux+uw9xe5meZGc2y9UKaVYRxD
	+YHbApvLqVcwmZSjSq4cXl5KHPGnDhWuqP6AL7IFgITEJBLVcT2vazYjSuKZyikheOp5vQyAoGi
	TOB1IS+Znhoc15YjWbRkARuwGpDK7AUOP/8U1gwTsHmyXCcE8Pg6WU0APi85C9oJSBmJxX4zyt7
	rKjXIA5nYInlgCyWzTZqKuYM2oH3sbkDfdwVdykbKrvqS7HaUbNdmd4n1Jzs3XhNDnvht632jzn
	L
X-Received: by 2002:a63:d50c:: with SMTP id c12mr4832308pgg.32.1549995850840;
        Tue, 12 Feb 2019 10:24:10 -0800 (PST)
X-Received: by 2002:a63:d50c:: with SMTP id c12mr4832279pgg.32.1549995850192;
        Tue, 12 Feb 2019 10:24:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549995850; cv=none;
        d=google.com; s=arc-20160816;
        b=K/+7niXdM6qjAxuIao/HuyoD+Qpan9q8af29MffT9CplkHIc3XzIoOtv7zbGLBMFDA
         LOD1h1HtCEdL/YEYoDO2FI8YrEkLy+hE9R8Vs0Xn7al3m3aCUFikRnBfAHrAvTEXO8Ms
         t+fpyPXr4jmoBZ3EPoNJMKJIecwAaRKhRv+j7PQnavr1fHMa//FP9B6oiibq/5+u/fnV
         xpI6k344dIs50gy1NF2fmmvnZZN7z5GLm2Ld7fhPO4CSupH1dWiCFDcNribcRk3lwTB5
         RFfVxTGjwSXs5tBYXNO6RMfzWzT7mgymlElcTRxHeT35hAnibVrouyrNIz7VBBDbI+k9
         JieA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=hCH7rykdmFoLvlo08xt1NV75vMDVG4DoRrkvFI4IOE8=;
        b=b2Hd0iB9Sn2xKDxO/XFhADw54sL1TfMXaLDTGkuMpycSH2mGN5L0LoWDgOTODN9Nux
         azFgRD9nRaZ2Epz4gEf/tL5HzvYgjdjJz+hLH/b+qMelLd4I0GNOmO6smMZNSIpqOKHy
         i13Gm1PjdHORCvASQooomgSIniFPHdeGgz5qJhHNniF0ah5mMSD6GT4yXURfyWHE1grl
         Z4CM6SoI9KsyArEI6vdFlW2SK+X4Dl20a/iz9GitAm1uwaxBkQdAq3+qT/w7MGJ5811P
         FhUQdriYzmTNFoGROoD5PXoOGfXoRQtAlDYft9HpklRmb3AsTmuV6zosLHvtdAg2fCoD
         ddig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Mx4KDzcP;
       spf=pass (google.com: domain of f.fainelli@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=f.fainelli@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v4sor7158325pfb.14.2019.02.12.10.24.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 10:24:10 -0800 (PST)
Received-SPF: pass (google.com: domain of f.fainelli@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Mx4KDzcP;
       spf=pass (google.com: domain of f.fainelli@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=f.fainelli@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:openpgp:autocrypt:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=hCH7rykdmFoLvlo08xt1NV75vMDVG4DoRrkvFI4IOE8=;
        b=Mx4KDzcPW7GFH1TMxdZx7ztlGPvIJXq6j7gkBphxsElTT1Ok2C4HLPWT2ScMW+4hxj
         4PbS70m7FSyBT/0i6dQSKiBqgL/MosnDIj5QoTGMtEYp19p6v0+OSodxWiyeGUP7+mN9
         1lAM1PZvxFMAfFoydb75E1O4f0ZgVyTpXDN+PsyYXlQ6NCziayhsrfCZaeKCLDtIitCD
         qEfRo69W+zZgq5YedTtV9yyiPBsVC1s87E0GYDZUuAFQp29caSoYooyiskxfA21DhqmU
         gOXnU+HqHJ9cmJ8ucqxameC5SOUfsaefPiAU/CfW7aJQGlxgXjyCV2IvxuTjDogqNFEn
         P9OQ==
X-Google-Smtp-Source: AHgI3IZ29xwNhEJ2AXzjv8zg0cFJuRW4Q0DThJATSowwWdyCQNzxo0LqQWgp1q2oV8eaE+WGubV0PA==
X-Received: by 2002:aa7:824f:: with SMTP id e15mr5122056pfn.192.1549995849568;
        Tue, 12 Feb 2019 10:24:09 -0800 (PST)
Received: from [10.67.48.220] ([192.19.223.250])
        by smtp.googlemail.com with ESMTPSA id b13sm27978211pfj.66.2019.02.12.10.24.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 10:24:07 -0800 (PST)
Subject: Re: [net-next PATCH V2 1/3] mm: add dma_addr_t to struct page
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
 =?UTF-8?Q?Toke_H=c3=b8iland-J=c3=b8rgensen?= <toke@toke.dk>,
 Ilias Apalodimas <ilias.apalodimas@linaro.org>, willy@infradead.org,
 Saeed Mahameed <saeedm@mellanox.com>,
 Alexander Duyck <alexander.duyck@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net,
 "David S. Miller" <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>
References: <154998290571.8783.11827147914798438839.stgit@firesoul>
 <154998294324.8783.9045146111677125556.stgit@firesoul>
 <dc34bb0b-1efd-4200-2ee7-bf8adef8a0b5@gmail.com>
 <20190212191917.2ef91a88@carbon>
From: Florian Fainelli <f.fainelli@gmail.com>
Openpgp: preference=signencrypt
Autocrypt: addr=f.fainelli@gmail.com; prefer-encrypt=mutual; keydata=
 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
 M5kY0ACeNhCZJvZ5g4C2Lc9fcTHu8jxmEkI=
Message-ID: <2d0de75d-960c-6866-b396-86490ca479af@gmail.com>
Date: Tue, 12 Feb 2019 10:23:52 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190212191917.2ef91a88@carbon>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/12/19 10:19 AM, Jesper Dangaard Brouer wrote:
> On Tue, 12 Feb 2019 10:05:39 -0800
> Florian Fainelli <f.fainelli@gmail.com> wrote:
> 
>> On 2/12/19 6:49 AM, Jesper Dangaard Brouer wrote:
>>> The page_pool API is using page->private to store DMA addresses.
>>> As pointed out by David Miller we can't use that on 32-bit architectures
>>> with 64-bit DMA
>>>
>>> This patch adds a new dma_addr_t struct to allow storing DMA addresses
>>>
>>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>>> Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
>>> Acked-by: Andrew Morton <akpm@linux-foundation.org>
>>> ---
>>>  include/linux/mm_types.h |    7 +++++++
>>>  1 file changed, 7 insertions(+)
>>>
>>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>>> index 2c471a2c43fa..581737bd0878 100644
>>> --- a/include/linux/mm_types.h
>>> +++ b/include/linux/mm_types.h
>>> @@ -95,6 +95,13 @@ struct page {
>>>  			 */
>>>  			unsigned long private;
>>>  		};
>>> +		struct {	/* page_pool used by netstack */
>>> +			/**
>>> +			 * @dma_addr: page_pool requires a 64-bit value even on
>>> +			 * 32-bit architectures.
>>> +			 */  
>>
>> Nit: might require? dma_addr_t, as you mention in the commit may have a
>> different size based on CONFIG_ARCH_DMA_ADDR_T_64BIT.
> 
> So you want me to change the comment to be:
> 
> /**
>  * @dma_addr: might require a 64-bit value even on
>  * 32-bit architectures.
>  */
> 
> Correctly understood?

Correct, that is what I would change. The commit message is correct, but
the comment makes it sound like dma_addr_t is guaranteed to be 64-bit,
while it is actually platform dependent. Does that make it clearer?
-- 
Florian

