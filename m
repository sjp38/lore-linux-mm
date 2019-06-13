Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A5CAC31E49
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:50:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BF5420851
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:50:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BF5420851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A82F18E0002; Thu, 13 Jun 2019 11:50:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0BCC8E0001; Thu, 13 Jun 2019 11:50:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8874A8E0002; Thu, 13 Jun 2019 11:50:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5D48E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:50:26 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id l10so3202909ljj.10
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:50:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BAQ3ZZbpFyn74ZZBbyfrvLcJL6fj+10PKW2YlRVqguw=;
        b=hdF8LNYvl80AqAY5IjijPZd0+VfYE8if8daDCetIh8rAL4/zTxwVQvsuASDXoZCeFE
         aJx2L1q4VyDvB48izfvEuhbc6Wfki9UjBBCJjNONyEwfX9TIgYBi0/5avx2H79bkWCaQ
         w7tCWG3yTvWWvDb5UWGfW/JbYhVOApa3S1NuebwrPez1WgUzjxDjeSmzK+jakaxV2So6
         ia2SWX7Nhubh1s0n7YgE8ruNGBY/Wp2U7ix0ht9bmZdE0EJRc3bw1H/ZQJ8tlBSH8UZ8
         n2YftaoOy/T4SOzpDkv0VsJUcOKVUi0kIFhKZYzMNm13NsKafXa3+uoioaumJ9tmMSRx
         MreQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAV9Zcsh4KfxUFpJq1DPURa1QTbUR5Vy+nXjDoy2Q8SxnLd0EGo9
	yoI9iyLT9DreSvNIVa/JM/sDU2K09st6TORQ8adWUR5lnYawVvZkgM/hhuwuL+YAxXIa8Hw0eKg
	RyJlubQlhdiQ2MUaLEBZYU3nU/YlQgWAakNwzxs/etLl2FMgEFZHzTmZOJVkX2MNOAw==
X-Received: by 2002:a19:4bc5:: with SMTP id y188mr45612907lfa.113.1560441025381;
        Thu, 13 Jun 2019 08:50:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyA3jj+J7/jNWhaaR5qQb3oUC+BS8MFIf98nJdR6LmEJ8CsZCjhlcYCre1UpRg654ZtGTig
X-Received: by 2002:a19:4bc5:: with SMTP id y188mr45612871lfa.113.1560441024572;
        Thu, 13 Jun 2019 08:50:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560441024; cv=none;
        d=google.com; s=arc-20160816;
        b=DQ7sF1VWWtiKiIz7yFmd4yleKZx9UOfi1Z1MfF74nG/8FE+Tn5zWmQkcJ90PvBTCpN
         vJdtaKhy/W1Venznf7R+rlNvB1OfMgKNEUqeD4pxLpkeK/K0W5v8MqLVdshYVasDPEF+
         AO++9so4VZ/VlO9NGVWS+yEo7ERqhSE5+C6YwbYeTNHwJJ/r/t2d3V494TSymNghJcIg
         F4re8eNrfe/wrjmZA8+PKy4KgAmJ4cLi6+SywnkEiOSdJsPT5xkdymBKlM1eXT08I4de
         cBebPz/4ri2h4Wdrn9RtZlukxWo0HuCB0L9aJ/ljRpLtintfuh7WuK+NWfDjOWVHmIHy
         9Rnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=BAQ3ZZbpFyn74ZZBbyfrvLcJL6fj+10PKW2YlRVqguw=;
        b=cymlmO4FA9XOac+75IihZfLMya02O/Ig9vNsJ/xJA7vTZkLJ+zDYLEz3FvHD72KdPM
         VnQ6qk6SBYa7CS2WNnzxDwwiA3RveEk0jxb2BsR5n3jeZ4ChD4+5SoSXDYERkFqgKI2z
         9iShRuzTdhGF35s0V9etFZyXTazd+ZWo3Ckl5FDTiCUP7nFwSri67LUE+iiqlYj5uRiP
         TEvjMPMoeTyoFwNQhjEuvuQJqiywBZzx7r7D4iVVYhht/6wkP8ngrSNktAfD6ihxz+h6
         kHPA9aQT7ppLm7NO0eGicANxVj49XVFFI6W1N7KtDJyTWtxOC0P2RGVt/TSZuBJQ6A3q
         wI2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id q30si31869lfb.86.2019.06.13.08.50.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 08:50:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hbRzR-0002en-B5; Thu, 13 Jun 2019 18:50:13 +0300
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Walter Wu <walter-zh.wu@mediatek.com>,
 Alexander Potapenko <glider@google.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Matthias Brugger <matthias.bgg@gmail.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>,
 Vasily Gorbik <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>,
 "Jason A . Donenfeld" <Jason@zx2c4.com>, Miles Chen
 <miles.chen@mediatek.com>, kasan-dev <kasan-dev@googlegroups.com>,
 LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 linux-mediatek@lists.infradead.org, wsd_upstream <wsd_upstream@mediatek.com>
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
 <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
 <CACT4Y+ZGEmGE2LFmRfPGgtUGwBqyL+s_CSp5DCpWGanTJCRcXw@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <278bd641-7d74-b9ac-1549-1e630ef3d38c@virtuozzo.com>
Date: Thu, 13 Jun 2019 18:50:25 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZGEmGE2LFmRfPGgtUGwBqyL+s_CSp5DCpWGanTJCRcXw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/13/19 4:05 PM, Dmitry Vyukov wrote:
> On Thu, Jun 13, 2019 at 2:27 PM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>> On 6/13/19 11:13 AM, Walter Wu wrote:
>>> This patch adds memory corruption identification at bug report for
>>> software tag-based mode, the report show whether it is "use-after-free"
>>> or "out-of-bound" error instead of "invalid-access" error.This will make
>>> it easier for programmers to see the memory corruption problem.
>>>
>>> Now we extend the quarantine to support both generic and tag-based kasan.
>>> For tag-based kasan, the quarantine stores only freed object information
>>> to check if an object is freed recently. When tag-based kasan reports an
>>> error, we can check if the tagged addr is in the quarantine and make a
>>> good guess if the object is more like "use-after-free" or "out-of-bound".
>>>
>>
>>
>> We already have all the information and don't need the quarantine to make such guess.
>> Basically if shadow of the first byte of object has the same tag as tag in pointer than it's out-of-bounds,
>> otherwise it's use-after-free.
>>
>> In pseudo-code it's something like this:
>>
>> u8 object_tag = *(u8 *)kasan_mem_to_shadow(nearest_object(cacche, page, access_addr));
>>
>> if (access_addr_tag == object_tag && object_tag != KASAN_TAG_INVALID)
>>         // out-of-bounds
>> else
>>         // use-after-free
> 
> But we don't have redzones in tag mode (intentionally), so unless I am
> missing something we don't have the necessary info. Both cases look
> the same -- we hit a different tag.

We always have some redzone. We need a place to store 'struct kasan_alloc_meta',
and sometimes also kasan_free_meta plus alignment to the next object.


> There may only be a small trailer for kmalloc-allocated objects that
> is painted with a different tag. I don't remember if we actually use a
> different tag for the trailer. Since tag mode granularity is 16 bytes,
> for smaller objects the trailer is impossible at all.
> 

Smaller that 16-bytes objects have 16 bytes of kasan_alloc_meta.
Redzones and freed objects always painted with KASAN_TAG_INVALID.

