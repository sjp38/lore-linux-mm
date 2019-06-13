Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70C19C31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 12:27:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 168572173C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 12:27:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 168572173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1A736B000E; Thu, 13 Jun 2019 08:27:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACA6E6B0266; Thu, 13 Jun 2019 08:27:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B9D16B026A; Thu, 13 Jun 2019 08:27:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 38B1A6B000E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:27:12 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id p3so2836176ljp.8
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:27:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=QyNWTj03afzaPDBn1iluZU89nDIXGRZJdacSCBorwio=;
        b=ggQY4yVJKcxPc1gYZ3f5smXMT5yoDB64UTQhMmD73Q0C6nRzbIh0BXulRWyQdD0ucJ
         I37eUNY0g5fsrWjcbX7lcIo0ai8c/22Ei+Y6Hra9KUtWD/9ggc14YDKSZQ35/aGM4/BM
         vf1cD/Mf+xedTxCmy48erdXHop3ByOINOrlpu+oWoHqplZSc/eq4JkEKxZErelVGbmVe
         lTl3JD+nFoE315K0PiWBms65B5FT7bLRqwefBU0P9J7ehMgUvoexCiop53OLmLWMO95G
         Ah3Q0NVdB2dl6FA6ZLh+U8rC3MMGsyCSFuETQJtwivGdhm397W78xwdJz6TPMjJsjbcu
         MZLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUvIWXXQcSGl+S6DiX+LStLwmd5HaKdZT3dICFcs3getZMYQqR8
	/z7f+I6/f29u6ZRiHrX9R0AI0G/9bPsh4cONp0VOnUHv2yeKetyarfLT57EhCEOwshSeNKG/w3h
	m1XT0o7j8VuegsPozL2BdzPa2KdXFn5ZsL2F5UQf44QNaKPlRPuzxD6/Sd2dTYSaSFg==
X-Received: by 2002:a19:6a01:: with SMTP id u1mr43042275lfu.141.1560428831699;
        Thu, 13 Jun 2019 05:27:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytcDEggMF9USzG4lOEGZmfKnqoi0BlP+bnY5DdKcbIbI6o+KYPJUfGT/mDnneVe/B70+B2
X-Received: by 2002:a19:6a01:: with SMTP id u1mr43042242lfu.141.1560428830914;
        Thu, 13 Jun 2019 05:27:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560428830; cv=none;
        d=google.com; s=arc-20160816;
        b=w7X2fQVACAZDmj7NrZLq4qu1yMeS2hTg4fYtid7yeJgh/o7kRGhzTFzLT+ZoS9MjaD
         et/cicBBBWNJ/qWwsfxFDroGYD/JKUoDAMaZu+wlMTcTZOwUl6u0l2NizUg/ibbTzZU/
         i2kbhyYkSYyEw8szg6LXPcCZRM9S+Z4YDsVdFJoCR633cl+boitvBLm3A7Eo28czkC1J
         Mxm4qqsdvTou26e/BjtnhL6a2eB+Pj68jqYHDPkGHflU5qqk8jpRQWUf28dhnvMmea9j
         6Plw70nLQwzqaKpmiJgLqh3Ld00VsplA1fJNQdYqbUYS7vaYUHbuNRVvh8fklpWj0r34
         P6CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QyNWTj03afzaPDBn1iluZU89nDIXGRZJdacSCBorwio=;
        b=Wh56jtEUUVjURW9rM/6zU27NPxH+e0nAjqbrDC+JkCNU+vUz7sjq5BV4Kdj9rn/cy/
         urllSAOXJpDlwu0bTU7k0L/7pj3tHKedzs3UkvecKzgqe8QfnpKhLM7ccpQmiBTaL7bz
         AB4NnUzfjTripQy9R25lN/RTrEaxpVnicXvGQHUeMRZLKDhO8A2z4pSUEj3u3ItC/0cX
         UZtoA3WRwibRCerOi6pgaQ0MVBR4VPOerGJvtQg4XdQf8v0A+xV7AXvxPYa3FfOxPb8G
         o0+TAUBO+Fz7Lb94aDSXzPsm7fqEgAt2LtMbfqGC7l0Fv/5oHA5HweuDvOJCrfjHqCOo
         GwAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id f17si2397943lfj.58.2019.06.13.05.27.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 05:27:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hbOol-000152-4t; Thu, 13 Jun 2019 15:26:59 +0300
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
To: Walter Wu <walter-zh.wu@mediatek.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Matthias Brugger <matthias.bgg@gmail.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>,
 Vasily Gorbik <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>,
 "Jason A . Donenfeld" <Jason@zx2c4.com>, Miles Chen <miles.chen@mediatek.com>
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org,
 linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
Date: Thu, 13 Jun 2019 15:27:09 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/13/19 11:13 AM, Walter Wu wrote:
> This patch adds memory corruption identification at bug report for
> software tag-based mode, the report show whether it is "use-after-free"
> or "out-of-bound" error instead of "invalid-access" error.This will make
> it easier for programmers to see the memory corruption problem.
> 
> Now we extend the quarantine to support both generic and tag-based kasan.
> For tag-based kasan, the quarantine stores only freed object information
> to check if an object is freed recently. When tag-based kasan reports an
> error, we can check if the tagged addr is in the quarantine and make a
> good guess if the object is more like "use-after-free" or "out-of-bound".
> 


We already have all the information and don't need the quarantine to make such guess.
Basically if shadow of the first byte of object has the same tag as tag in pointer than it's out-of-bounds,
otherwise it's use-after-free.

In pseudo-code it's something like this:

u8 object_tag = *(u8 *)kasan_mem_to_shadow(nearest_object(cacche, page, access_addr));

if (access_addr_tag == object_tag && object_tag != KASAN_TAG_INVALID)
	// out-of-bounds
else
	// use-after-free

