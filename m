Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFEF2C282CC
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 00:30:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BEDC2080D
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 00:30:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="kF+DA96O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BEDC2080D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C7928E006D; Thu,  7 Feb 2019 19:30:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 177778E0002; Thu,  7 Feb 2019 19:30:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 090E28E006D; Thu,  7 Feb 2019 19:30:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFB478E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 19:30:12 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id q33so1789997qte.23
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 16:30:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=RMe7AVsMjh+VkK1x7GiCCnejt907H2ljXbmC15yNzuI=;
        b=RUDnNemJWYQEuP89scY3HSu1Qs4RRNuR7ZHHK3+qIRoLGnQUtX+OuVrRQ4grxU842T
         iskwUkWCeb+JHt7PkwpV890jz0onN7S/bxv3maejP9wHXy+NRU4ReMN0HB6iqIq0ihSK
         c/Os9V9ZoJee1Vt4RXDFbycF+XYkJUfaAAfQhBqnqJ2rLk8X4neLkyGDyrQJRxVkPDB9
         9C2TGMRE54eTk7TRhx8TeGXqlfooqGqT7Lz86kMNTaxeAxNt4ybYXT7t83J+7F0yDLq1
         8KIqVXjBYBCjXbdlcthh1dL1VlOmG79rdUG4guxI4Y63xf9clzw1awMYMzOMR4NOe+nX
         f2aw==
X-Gm-Message-State: AHQUAuaw7gUWAZmqE6suy8YwUbzcDgD+MbnG+S1G5oMGCNjPTSVInK7G
	CNQYPtWjpuL6YSiHAIbJOXZ+taEhEtzegfiSRmpCvMAo2GLV6mbP0jBWWHysgkcSaVny6knB9rk
	v7YdRkaNQ0KB5S2YghmQk1M91TGCAA000bBKVstW7YHBicLvxKrUnRgbnZpjd0Y92FmnIsd/duj
	sn2f/sXrwYLZ8FW9JW6gsNrwdyxWIJxKm0T18+hxY0Mv/1iC6dr8wq82KGGSTFHF0sfz2mgtTbG
	FoVmvoNPIp1mS6y949kMyfHQ6vMYGxttHL+TyuaGJHFHD6hu/9KjiZnxNafrQWBjcdQlpGd3zcs
	TvvMpkTBf43FN/fXXy3VLTl5ggOtphC2EQd0hAHYGn1wgMa8VZaBKtnXPMW6l2HeAqc99m1D52Y
	U
X-Received: by 2002:ac8:32ef:: with SMTP id a44mr12029020qtb.334.1549585812621;
        Thu, 07 Feb 2019 16:30:12 -0800 (PST)
X-Received: by 2002:ac8:32ef:: with SMTP id a44mr12028989qtb.334.1549585812200;
        Thu, 07 Feb 2019 16:30:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549585812; cv=none;
        d=google.com; s=arc-20160816;
        b=fb3qDShjjtSaZ2SnvLAt6ALgmVINvldOZcPX8bga1OSUuuHmuwHcDNEL1VS43AjiG3
         Z1AVhV/swHE5DsxSwl9KJqfXdQ4NL1O2aT0Zq1eVh+hggZsCrUDgruO2DjZe0Mc6Wswy
         nm/FWgWrPqBAdxDyhiK7Dkq2LQgXCZK3ertTUzwApt7wMRSDdvV01tYQixKSqpmVslNi
         NaF/jp4bAgLGEzK+/08ObpNZo0Aizde2fB5OhKnZXO/4nQYrB0xgXeo6kO7++nS5hTNK
         jDUfFMmFYVipnEnDaMVBf97m9WsA8uz6fvUcs3J5GcpLAkzO5q0AvQVucARWjJlt2nye
         6DMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=RMe7AVsMjh+VkK1x7GiCCnejt907H2ljXbmC15yNzuI=;
        b=ItBIYqciFMMmV2AyD7KLbmU0kI4N8saLfAC/R5++70hXc3qZEa5SFkfmiEcz97i6Rw
         mr0gD3R3Y0+QRfzprD7AcoIlL9HSXQqEJ8O2WqLh2qjwc2erbypwFee7XgehWITlt9Uz
         MsqBf4L5IopTBE7DRmJRxc9+/b/eiN0xJG26eByhBB9nedIlYmhvDYbktQMLOlIFXC+k
         V/mcfO72yNANIL9F2hHYe19vpE6eDjpILn9tZ81tA4KpbZjjpDL8klNIg4HcPmGBAKEA
         Ywla7C4zFax/MrsTX7LtOLnvLLVOVHCS/7nhUxr0uTIoldNbeXaNdKnV+TJaKI+2C0j+
         r/vA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=kF+DA96O;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u10sor572017qtg.72.2019.02.07.16.30.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 16:30:12 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=kF+DA96O;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=RMe7AVsMjh+VkK1x7GiCCnejt907H2ljXbmC15yNzuI=;
        b=kF+DA96OlADNN+EubsYiqoqNkvnBYeSDHZSDiaQmqWpMfp9KPsvdGqSGMnUB7lMdCh
         XyaFyJyor0TFQbZkgK/5f1zdFNoM8UEt1S33/p/VQ3OiXhWgIqB73WbDxf0jXVm5f2BN
         RZ4op8XWlwKd88q+odancnWkE4zrt1Dc0XdkT3x+dY+W7B4n/QWBT8bhqkQXDOYDtrfl
         QhePtXjQ++Wpm4rOzswQCvnsssrQJgQjZdSQDXNIFQzYfKM7gO2gsYQMocWRKv39S/Aa
         WuJyHXfH+6RzFLfZpBJVfnuFEkmztOzWbNWadgbeZOgeYGhFHcgZ3NWtZkAYRIlsDTyg
         ZYcA==
X-Google-Smtp-Source: AHgI3IYzwOR0xRYy4WWnLHqFOwTXXHOpIy9YHGqmQ6MRjp23/KzxqwEu0PZxYDtVkcajAuwqw8B/kQ==
X-Received: by 2002:ac8:2783:: with SMTP id w3mr14328224qtw.221.1549585811735;
        Thu, 07 Feb 2019 16:30:11 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id g3sm457393qkc.54.2019.02.07.16.30.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 16:30:11 -0800 (PST)
Subject: Re: CONFIG_KASAN_SW_TAGS=y NULL pointer dereference at
 freelist_dereference()
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 kasan-dev <kasan-dev@googlegroups.com>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Linux-MM <linux-mm@kvack.org>
References: <b1d210ae-3fc9-c77a-4010-40fb74a61727@lca.pw>
 <CAAeHK+yzHbLbFe7mtruEG-br9V-LZRC-n6dkq5+mmvLux0gSbg@mail.gmail.com>
 <89b343eb-16ff-1020-2efc-55ca58fafae7@lca.pw>
 <CAAeHK+zxxk8K3WjGYutmPZr_mX=u7KUcCUYXHi+OgRYMfcvLTg@mail.gmail.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <d8cdc634-0f7d-446e-805a-c5d54e84323a@lca.pw>
Date: Thu, 7 Feb 2019 19:30:10 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <CAAeHK+zxxk8K3WjGYutmPZr_mX=u7KUcCUYXHi+OgRYMfcvLTg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/7/19 10:34 AM, Andrey Konovalov wrote:
> Reproduced, looks like a conflict with CONFIG_SLAB_FREELIST_HARDENED.
> Could you try the attached patch?
> 

You nailed it!

