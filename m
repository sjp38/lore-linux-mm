Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58880C04AB3
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 22:18:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1025820989
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 22:18:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1025820989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92AE96B0003; Thu,  9 May 2019 18:18:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DC496B0006; Thu,  9 May 2019 18:18:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A25F6B0007; Thu,  9 May 2019 18:18:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1686B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 18:18:57 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id u65so3546903qkd.17
        for <linux-mm@kvack.org>; Thu, 09 May 2019 15:18:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=2EPdXAef+pz2LaS1HGnNdfLDb/96fuCCGO2V3Uyxmtk=;
        b=UZi64rZ+l10+uSRAfu18l+df1TCzyLVQAprYxslnvHHZZ+6rUDicpvVYAzFtZjgX4O
         uP8li7I7XGcduITGSdoHXfe6IKnI1G1gazQ1+Sg4fb+cfMb0Ek/tW27UJ2RYEku0mH3z
         EVoEXj/41digzVw8I332gPa8YoHpEoEwM51oBd4HevrAyNpRwhRLJtq5ONc4wCXmOCla
         H5ttprZ/Qbljx80GKK3HWixIMpQzDsdwsGIlnIK5nGqAUBk4A5mdes9pRIXenLWfHWin
         nY4cj2hJgIUQt0lXCggRHTm2WtOo+QgYAdx0SVAQPRW+XqiBUd/QVeyPRg9pFahAQaXd
         KVqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWUrdm0MuVmUeww2U9PSM4FheknQlY0LMry5Bl7TWO5sje+pyFg
	A75tiPAu+4iviK3lA3W2VUNncBGvp6UFyjKl2OPnmTVaisZMcmJhZLXDPmaO7HvUI5vJngo/kx4
	yh5AcmfppnEFnnqSArkwmrXzr2AuiDOo+6d6SZR11xkml0/0kOOkbnS36BbRpQrL4HA==
X-Received: by 2002:ad4:4587:: with SMTP id x7mr5946648qvu.192.1557440337135;
        Thu, 09 May 2019 15:18:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtkem8UUhr6mBCgpt9mQb17AZZ/1ocgVS833qNht5Fl5MTb4mnbX5Me+PSgdoOt+5kPq8W
X-Received: by 2002:ad4:4587:: with SMTP id x7mr5946589qvu.192.1557440336462;
        Thu, 09 May 2019 15:18:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557440336; cv=none;
        d=google.com; s=arc-20160816;
        b=mrO9VoxM1ZgdvB8HS0lcnqMVfzFONMHP6q7QQe7FJi4IC/1iyO6noJbGzBBCU5hxeS
         v3UkoF3U8urxmgclnRCLeWRfg6XS+TbZ01gQUi0f5sGJaoPinYLt7xZ4wDhCumVs1MZg
         jjfddl1B7wtqTZ376e9QRpDu2U+eG2MZzywBN8DMSXnRG2i78omrrYxUmtkpoyeegF//
         qQswSCHZNBDD5Oz+ndYJ4KSGmSFLaxz3jV0MFoNhCE7Eqw1nhmJgeQirMKwsWZq0yS0h
         VmdBMqIeXuEe9mybc7+srAEv/cZiPbJzXNenYQRpuTq/ZEnPFrhL0inuwhwuTlDvE6Jv
         JPww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=2EPdXAef+pz2LaS1HGnNdfLDb/96fuCCGO2V3Uyxmtk=;
        b=wsq07QyCRdCkgZNHhbeQBsmAlrVh9UpTUVE+rTaF2aRNWWhLY415RkFuJbU0C06vte
         kKXRshv9+wYfZZ/uizd5TBM2if0A2vdJQ+7gZ1VDhGqfUNZjebZsGtEMEavCw3wnfQKo
         cwBPk/jr+UgODYBAMnMtHq4SgPX5wjB4vhTgwK15tliOOYRXqDQH8cPE9KbflGjp4Cky
         LGVS7QgKFvhcld4p+OffhPdlfVNKZUfz6/J0k2BC/XdZNbYEwrpz7/8GlhVmDu/5QFMj
         Byxbvs1EUZeRcemTRwbH/Kz6J/3gXsMTsCPV6GAE9cDzLeNq4go4vuu0kdW9LtxjwPy/
         D4hA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d42si2367442qtd.76.2019.05.09.15.18.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 15:18:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4D7973082137;
	Thu,  9 May 2019 22:18:55 +0000 (UTC)
Received: from [10.36.116.110] (ovpn-116-110.ams2.redhat.com [10.36.116.110])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 50ADC5D9C4;
	Thu,  9 May 2019 22:18:51 +0000 (UTC)
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>, Ingo Molnar <mingo@kernel.org>,
 Andrew Banman <andrew.banman@hpe.com>, Oscar Salvador <osalvador@suse.de>,
 Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>,
 Mathieu Malaterre <malat@debian.org>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-5-david@redhat.com>
 <20190509143151.zexjmwu3ikkmye7i@master>
 <28071389-372c-14eb-1209-02464726b4f0@redhat.com>
 <20190509215034.jl2qejw3pzqtbu5d@master>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 xsFNBFXLn5EBEAC+zYvAFJxCBY9Tr1xZgcESmxVNI/0ffzE/ZQOiHJl6mGkmA1R7/uUpiCjJ
 dBrn+lhhOYjjNefFQou6478faXE6o2AhmebqT4KiQoUQFV4R7y1KMEKoSyy8hQaK1umALTdL
 QZLQMzNE74ap+GDK0wnacPQFpcG1AE9RMq3aeErY5tujekBS32jfC/7AnH7I0v1v1TbbK3Gp
 XNeiN4QroO+5qaSr0ID2sz5jtBLRb15RMre27E1ImpaIv2Jw8NJgW0k/D1RyKCwaTsgRdwuK
 Kx/Y91XuSBdz0uOyU/S8kM1+ag0wvsGlpBVxRR/xw/E8M7TEwuCZQArqqTCmkG6HGcXFT0V9
 PXFNNgV5jXMQRwU0O/ztJIQqsE5LsUomE//bLwzj9IVsaQpKDqW6TAPjcdBDPLHvriq7kGjt
 WhVhdl0qEYB8lkBEU7V2Yb+SYhmhpDrti9Fq1EsmhiHSkxJcGREoMK/63r9WLZYI3+4W2rAc
 UucZa4OT27U5ZISjNg3Ev0rxU5UH2/pT4wJCfxwocmqaRr6UYmrtZmND89X0KigoFD/XSeVv
 jwBRNjPAubK9/k5NoRrYqztM9W6sJqrH8+UWZ1Idd/DdmogJh0gNC0+N42Za9yBRURfIdKSb
 B3JfpUqcWwE7vUaYrHG1nw54pLUoPG6sAA7Mehl3nd4pZUALHwARAQABzSREYXZpZCBIaWxk
 ZW5icmFuZCA8ZGF2aWRAcmVkaGF0LmNvbT7CwX4EEwECACgFAljj9eoCGwMFCQlmAYAGCwkI
 BwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEE3eEPcA/4Na5IIP/3T/FIQMxIfNzZshIq687qgG
 8UbspuE/YSUDdv7r5szYTK6KPTlqN8NAcSfheywbuYD9A4ZeSBWD3/NAVUdrCaRP2IvFyELj
 xoMvfJccbq45BxzgEspg/bVahNbyuBpLBVjVWwRtFCUEXkyazksSv8pdTMAs9IucChvFmmq3
 jJ2vlaz9lYt/lxN246fIVceckPMiUveimngvXZw21VOAhfQ+/sofXF8JCFv2mFcBDoa7eYob
 s0FLpmqFaeNRHAlzMWgSsP80qx5nWWEvRLdKWi533N2vC/EyunN3HcBwVrXH4hxRBMco3jvM
 m8VKLKao9wKj82qSivUnkPIwsAGNPdFoPbgghCQiBjBe6A75Z2xHFrzo7t1jg7nQfIyNC7ez
 MZBJ59sqA9EDMEJPlLNIeJmqslXPjmMFnE7Mby/+335WJYDulsRybN+W5rLT5aMvhC6x6POK
 z55fMNKrMASCzBJum2Fwjf/VnuGRYkhKCqqZ8gJ3OvmR50tInDV2jZ1DQgc3i550T5JDpToh
 dPBxZocIhzg+MBSRDXcJmHOx/7nQm3iQ6iLuwmXsRC6f5FbFefk9EjuTKcLMvBsEx+2DEx0E
 UnmJ4hVg7u1PQ+2Oy+Lh/opK/BDiqlQ8Pz2jiXv5xkECvr/3Sv59hlOCZMOaiLTTjtOIU7Tq
 7ut6OL64oAq+zsFNBFXLn5EBEADn1959INH2cwYJv0tsxf5MUCghCj/CA/lc/LMthqQ773ga
 uB9mN+F1rE9cyyXb6jyOGn+GUjMbnq1o121Vm0+neKHUCBtHyseBfDXHA6m4B3mUTWo13nid
 0e4AM71r0DS8+KYh6zvweLX/LL5kQS9GQeT+QNroXcC1NzWbitts6TZ+IrPOwT1hfB4WNC+X
 2n4AzDqp3+ILiVST2DT4VBc11Gz6jijpC/KI5Al8ZDhRwG47LUiuQmt3yqrmN63V9wzaPhC+
 xbwIsNZlLUvuRnmBPkTJwwrFRZvwu5GPHNndBjVpAfaSTOfppyKBTccu2AXJXWAE1Xjh6GOC
 8mlFjZwLxWFqdPHR1n2aPVgoiTLk34LR/bXO+e0GpzFXT7enwyvFFFyAS0Nk1q/7EChPcbRb
 hJqEBpRNZemxmg55zC3GLvgLKd5A09MOM2BrMea+l0FUR+PuTenh2YmnmLRTro6eZ/qYwWkC
 u8FFIw4pT0OUDMyLgi+GI1aMpVogTZJ70FgV0pUAlpmrzk/bLbRkF3TwgucpyPtcpmQtTkWS
 gDS50QG9DR/1As3LLLcNkwJBZzBG6PWbvcOyrwMQUF1nl4SSPV0LLH63+BrrHasfJzxKXzqg
 rW28CTAE2x8qi7e/6M/+XXhrsMYG+uaViM7n2je3qKe7ofum3s4vq7oFCPsOgwARAQABwsFl
 BBgBAgAPBQJVy5+RAhsMBQkJZgGAAAoJEE3eEPcA/4NagOsP/jPoIBb/iXVbM+fmSHOjEshl
 KMwEl/m5iLj3iHnHPVLBUWrXPdS7iQijJA/VLxjnFknhaS60hkUNWexDMxVVP/6lbOrs4bDZ
 NEWDMktAeqJaFtxackPszlcpRVkAs6Msn9tu8hlvB517pyUgvuD7ZS9gGOMmYwFQDyytpepo
 YApVV00P0u3AaE0Cj/o71STqGJKZxcVhPaZ+LR+UCBZOyKfEyq+ZN311VpOJZ1IvTExf+S/5
 lqnciDtbO3I4Wq0ArLX1gs1q1XlXLaVaA3yVqeC8E7kOchDNinD3hJS4OX0e1gdsx/e6COvy
 qNg5aL5n0Kl4fcVqM0LdIhsubVs4eiNCa5XMSYpXmVi3HAuFyg9dN+x8thSwI836FoMASwOl
 C7tHsTjnSGufB+D7F7ZBT61BffNBBIm1KdMxcxqLUVXpBQHHlGkbwI+3Ye+nE6HmZH7IwLwV
 W+Ajl7oYF+jeKaH4DZFtgLYGLtZ1LDwKPjX7VAsa4Yx7S5+EBAaZGxK510MjIx6SGrZWBrrV
 TEvdV00F2MnQoeXKzD7O4WFbL55hhyGgfWTHwZ457iN9SgYi1JLPqWkZB0JRXIEtjd4JEQcx
 +8Umfre0Xt4713VxMygW0PnQt5aSQdMD58jHFxTk092mU+yIHj5LeYgvwSgZN4airXk5yRXl
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <c5cfec90-8837-8d84-29fa-564e4e5923a1@redhat.com>
Date: Fri, 10 May 2019 00:18:50 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190509215034.jl2qejw3pzqtbu5d@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 09 May 2019 22:18:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Looks good to me.
> 
>>
>> (I would actually even prefer "memory_block_devices", because memory
>> blocks have different meanins)
>>
> 
> Agree with you, this comes to my mind sometime ago :-)

We have memblocks, memory_blocks  ... I guess memory_block_device is
unique :)

> 
>>>
>>> [...]
>>>
>>>> /*
>>>> @@ -1106,6 +1100,13 @@ int __ref add_memory_resource(int nid, struct resource *res)
>>>> 	if (ret < 0)
>>>> 		goto error;
>>>>
>>>> +	/* create memory block devices after memory was added */
>>>> +	ret = hotplug_memory_register(start, size);
>>>> +	if (ret) {
>>>> +		arch_remove_memory(nid, start, size, NULL);
>>>
>>> Functionally, it works I think.
>>>
>>> But arch_remove_memory() would remove pages from zone. At this point, we just
>>> allocate section/mmap for pages, the zones are empty and pages are not
>>> connected to zone.
>>>
>>> Function  zone = page_zone(page); always gets zone #0, since pages->flags is 0
>>> at  this point. This is not exact.
>>>
>>> Would we add some comment to mention this? Or we need to clean up
>>> arch_remove_memory() to take out __remove_zone()?
>>
>> That is precisely what is on my list next (see cover letter).This is
>> already broken when memory that was never onlined is removed again.
>> So I am planning to fix that independently.
>>
> 
> Sounds great :-)

Especially, I suspect a lot of bugs in the area of

1. Remove memory that has never been onlined
2. Remove memory that has been onlined/offlined a couple of times
3. Remove memory that has been onlined to different zones.

Will see when refactoring if my intuition is right :)

> 
> Hope you would cc me in the following series.


Sure! Thanks!


-- 

Thanks,

David / dhildenb

