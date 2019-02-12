Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFFBDC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:16:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE5002075C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:16:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="panJKHgc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE5002075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F6478E0005; Tue, 12 Feb 2019 10:16:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A58E8E0001; Tue, 12 Feb 2019 10:16:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 495878E0005; Tue, 12 Feb 2019 10:16:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 191E18E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:16:00 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id c67so1898752ywe.5
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:16:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=RqtMyuSranbSJ6NlUU6s0xosq9CQZC03joN1XI2VuCQ=;
        b=c876SM64zgmqQvRIqOjTfNBYp5lh7JhyGthDeiydCzouln3ig4tUHQKShu6BokQL28
         DyYAexwOXbYQXU8luN1X+JDDb3YcrCNBllCCNjjkttrgQ1gRcVtLyryFgr83LYWOCskp
         3qecXF1OmAD3wzuPzDKOzbr+5dwFOhdWguIfvCXigfRbIWg7LyalfJsxZ+hyMg/Mq9TD
         uyOrFVeocr55UJf9Aaa03Khyeunmvf1mL83JPlRWFEtNI5C5yMuOwS3UTSS3AgcrkuU+
         XhaCCVI/H4SVB0nIsKi6lJhW2BWjNfLS2HDYorvUAZ2DMJU27tb+OupFrbtyLUCowudH
         y5qw==
X-Gm-Message-State: AHQUAuYGV1EnzLfPCzygaUBhDyGEToto48Nurdww5NIo06fyY+TTS9rn
	7a8mYUVXsk61vxGDvOxg2C1evoT7CiGfish9opHsr8BzMEJ4ocgzrTnQQBvG1UW3V5gJNrh8gpO
	KITAzvVeaTMxmdKKr6PsXlTt8fgC2QnDwsfxNTjMhLEBK38AE4H9gBvsU4Zctq50RFnF3Q6y4lR
	LDlLI3JvKtE0kj9GaHosQ5Br8+73omc7g6XSZv+FdfVop50zibBnkGKitfnRpxB4gY73R5dZca9
	sjjC/Xh6yrIKPq2X8qCsFH28PweIhFe4yPXNIBFrEo1UKDPKWgCQyMxPU3P3JxHM0N1DnDtqmua
	bauneFB7iKI2CqIZ0x9iCNjUISyanM/5ZWHGFtTYBgnBTq5iMJ2mbOdWz4IVPNIjgAAv8DHw4DP
	0
X-Received: by 2002:a5b:3ca:: with SMTP id t10mr3302430ybp.304.1549984559739;
        Tue, 12 Feb 2019 07:15:59 -0800 (PST)
X-Received: by 2002:a5b:3ca:: with SMTP id t10mr3302379ybp.304.1549984559146;
        Tue, 12 Feb 2019 07:15:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549984559; cv=none;
        d=google.com; s=arc-20160816;
        b=rwaW6ZWVqhIW9dqUAajFMiK3Szi3vjuINXItLQkytu1fBKbmY7mUUd+mr7I9BTbS1o
         LdEHJ1cs/fXAHrdwhnMnHnt8PI2Av9Ns7d8wMTBqbMOU69BG9wJ3sr7t7nCnZAL5c772
         sgobtoru7W1yAMqrPSCGP7Z8bk3NeC4gdWm8z1FZrvYHJ+yLjGahx3cnSoambfyFfWQT
         LfmDKNKw65Ntsk6eNbphzL741ayX6blxLTAe1IiQzPoNBSUMC5FnJTuciuvAyIbRyNga
         1kCSsIQHt4o1Af+eAaYkuaB11s+wS/7mERkY9VOR3sdqhkDfulbtawShe3dtwc6J5oDP
         QysQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=RqtMyuSranbSJ6NlUU6s0xosq9CQZC03joN1XI2VuCQ=;
        b=jqzA8qvnSsuySKvvNd1t3mFFZc0X7lVGqBMyqDMh4hNZmHE3dRaIBtafTBq50bNQia
         95w2l/FFfhg5V6cYeoDZN5hw8Z9KQadsqZevaOSL8S4H32VOmPrccFWzFUCw5S0TtTnG
         RuLPQxOBwFAF8Dqaym1mEsxt7LleAG19SNBLzqKmVrrau2BHWelNxQdOskYZ5dMswUt4
         ZoW80lsQk/0cKZLvbvLz/2JSEWPuXvNor5bwCG3HGvIFVY87VnfyUeV19lDsVqMUbBmq
         ZrmSFCs5inb05EITMkB0s238HTsPrw8FE2SHoQKfiDYSfoQc9g2z8Y5qwfvhpzWGiYNw
         MG6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=panJKHgc;
       spf=pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eric.dumazet@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k2sor7417062ybh.203.2019.02.12.07.15.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 07:15:59 -0800 (PST)
Received-SPF: pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=panJKHgc;
       spf=pass (google.com: domain of eric.dumazet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=eric.dumazet@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=RqtMyuSranbSJ6NlUU6s0xosq9CQZC03joN1XI2VuCQ=;
        b=panJKHgcgOBhqJJPlBiMOZuPpZJzMk8Bngw9oHg3r6OueyqqakoAeebYaci/3edrMh
         8fQmo7xAyAIBUQ80E4+CTSWybvrJ+Wj6CY4Zkt/46N0udIcNoAKcXILLmvD4iFafPJMr
         7d6tF6I1ZvUKr463+PPLUhYrmCD0GmbH2YLoSSEd08Iqgx+bmBFxpAFVrt1J4nz9XHC6
         LMhTqwX8tEb/btFO2mNwXEBD7cyb/gHpnUIsQ4/ggpS5u+Vj8HqPm5vhEHm+0JtJCvru
         yHHFxJBJ1Ho9gLKvPfpIVflOZi1pv+HA1BTRowQWeHb72rNLCkH301R854Hsbnubl9C6
         6+/g==
X-Google-Smtp-Source: AHgI3IZfH0OCDGgp4potPiLlLuyWCzWBKkni/gD2JL9ai09luPJas2if4VY50FKbOZzF44s523/yhQ==
X-Received: by 2002:a25:b98d:: with SMTP id r13mr3384874ybg.400.1549984558622;
        Tue, 12 Feb 2019 07:15:58 -0800 (PST)
Received: from [192.168.86.235] (c-73-241-150-70.hsd1.ca.comcast.net. [73.241.150.70])
        by smtp.gmail.com with ESMTPSA id g127sm4940451ywf.38.2019.02.12.07.15.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:15:57 -0800 (PST)
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
To: Tariq Toukan <tariqt@mellanox.com>, Eric Dumazet
 <eric.dumazet@gmail.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>,
 Matthew Wilcox <willy@infradead.org>, "brouer@redhat.com" <brouer@redhat.com>
Cc: David Miller <davem@davemloft.net>, "toke@redhat.com" <toke@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "mgorman@techsingularity.net" <mgorman@techsingularity.net>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
 <20190207150745.GW21860@bombadil.infradead.org>
 <20190207152034.GA3295@apalos>
 <20190207.132519.1698007650891404763.davem@davemloft.net>
 <20190207213400.GA21860@bombadil.infradead.org>
 <20190207214237.GA10676@Iliass-MBP.lan>
 <bfd83487-7073-18c8-6d89-e50fe9a83313@mellanox.com>
 <64f7af75-e6df-7abc-c4ce-82e6ca51fafe@gmail.com>
 <27e97aac-f25b-d46c-3e70-7d0d44f784b5@mellanox.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <d8fa6786-c252-6bb0-409f-42ce18127cb3@gmail.com>
Date: Tue, 12 Feb 2019 07:15:55 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <27e97aac-f25b-d46c-3e70-7d0d44f784b5@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/12/2019 04:39 AM, Tariq Toukan wrote:
> 
> 
> On 2/11/2019 7:14 PM, Eric Dumazet wrote:
>>
>>
>> On 02/11/2019 12:53 AM, Tariq Toukan wrote:
>>>
>>
>>> Hi,
>>>
>>> It's great to use the struct page to store its dma mapping, but I am
>>> worried about extensibility.
>>> page_pool is evolving, and it would need several more per-page fields.
>>> One of them would be pageref_bias, a planned optimization to reduce the
>>> number of the costly atomic pageref operations (and replace existing
>>> code in several drivers).
>>>
>>
>> But the point about pageref_bias is to place it in a different cache line than "struct page"
>>
>> The major cost is having a cache line bouncing between producer and consumer.
>>
> 
> pageref_bias is meant to be dirtied only by the page requester, i.e. the 
> NIC driver / page_pool.
> All other components (basically, SKB release flow / put_page) should 
> continue working with the atomic page_refcnt, and not dirty the 
> pageref_bias.

This is exactly my point.

You suggested to put pageref_bias in struct page, which breaks this completely.

pageref_bias is better kept in a driver structure, with appropriate prefetching
since most NIC use a ring buffer for their queues.

The dma address _can_ be put in the struct page, since the driver does not dirty it
and does not even read it when page can be recycled.

