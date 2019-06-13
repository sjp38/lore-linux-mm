Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78BDCC31E49
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:35:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D5A1206BB
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:35:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D5A1206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E374A6B0008; Thu, 13 Jun 2019 11:35:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE76A6B000C; Thu, 13 Jun 2019 11:35:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD6FC6B026A; Thu, 13 Jun 2019 11:35:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0DD6B0008
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:35:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so26358498edv.16
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:35:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=aKt9HRBGnsuYA5qlAM9OULXQ7rlyJl5/33nUWsYNM08=;
        b=SVS1WORUFuHZKg4CZcP8LtDX58UBOsygFq3XeG9nyAfYEjX2DlIl6Jr/pgEwZw6L/Z
         Xln3NGOLfAv3XJ9vU+h786jVXytvd3mjGL0h9/sHcJiGD3bMnvO2jL4aaUULEg6KLcRL
         fe0bl9V58LlzkQxfJiWYcgepG9wadjBmYqVjjcLrJ94HmW4lmZriLR+VS6/6plKJ4+9x
         o21b0zbqqpePljLdeIP6ypkRhACzubyV7VOcmPmC5KVwlx90eSemhWBFQfhH2lxC+F7r
         Qh6rnpHWS/ZxNMd0CwNBsyPDu2yHY01Gb7nJ8H1OhtVN+LgFBO2/yVF+v0l1KPdJopAm
         v7Hg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAXdqfkkV+nr6D52DdxVkYPC4l0vjpYqIdohj3nWEnuFivV/60rB
	oV1I0PrgxN9KGJi2N43tjvpat/ajWzXyrD9OdBhVZdr+6CyCvUjkinklNaf7vS2AnpmGMuRiZqo
	mnJOUxcg9OulJVAOsGZrukrv0w7wlR62y97LQM6sSFfb5t/2uDIZenlwck5WyNMDtCA==
X-Received: by 2002:a50:97da:: with SMTP id f26mr59393625edb.88.1560440140076;
        Thu, 13 Jun 2019 08:35:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymyiIO205U97EBr9qSPurz4PvIJqb9FAep5u8TQXdF1VrepnlW4yOmTMWTQ4KS8mRc0oJk
X-Received: by 2002:a50:97da:: with SMTP id f26mr59393544edb.88.1560440139274;
        Thu, 13 Jun 2019 08:35:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560440139; cv=none;
        d=google.com; s=arc-20160816;
        b=jON0l/epHU+Gsl/p+Mzsx9LOH96TxOfa/M33BV8HqsttM3BSQolBDLHsitEvYTMAJv
         8zrlu/wFqZ5g+kr04B/LeK1EIoyPft8MvxB0dYIxkoD1RxnjSghMLhbcui5j4f5yt6NW
         pEX0ZIwlly7Q/rRaaa8ViHGovYtJCVixb/33sriIqHrli/oN8F4nWvmzh3ecB+lYJcX4
         Woxh0fscPfIJAaZQcpGHbuwV1iXmweJUGsJfG+NXMBkSrcDTAx1QpDGAjOgt+IVTJPLK
         vhf4DO4abq2muNExlBniqhR86lubcJpxEXyjOGn4kilXzYL84hZlCyuBlMYx6nZPI5tO
         5N3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=aKt9HRBGnsuYA5qlAM9OULXQ7rlyJl5/33nUWsYNM08=;
        b=JpgeVoPu/AX4Zsio/Dqf7K/9fRfIUPhpPNa8N2dZU6FF+jBEhHFAKb/z8ywjT/4GZY
         GGJB8pesANW99YYggnxKZ92e14QjOKby6sexie84DtsrLHlEUQorI8sZJlkeAsBPZFhG
         uveCjhkgjC2b5T2+/dJ3xy4B0pq2Z8B6wk96Y0DG6d9hj4o6wp0JcZbPc6zrn2RLXhZS
         c/t9ln+NXUvFYUv+/qWylAkPSURPyum5+LAs1vaFlNvhvCkIfe0pBxu+SOwurvdsDYoR
         b7OC0GGWcB4jJtZXO/k10L3fnrDc97Mr656TTZu/wtsuFVP/GxY+zfjzHfMtr7mqQz7S
         /59w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id y47si2640094edb.94.2019.06.13.08.35.38
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 08:35:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 42C42A78;
	Thu, 13 Jun 2019 08:35:38 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 458113F718;
	Thu, 13 Jun 2019 08:35:36 -0700 (PDT)
Subject: Re: [PATCH v4 1/2] arm64: Define
 Documentation/arm64/tagged-address-abi.txt
To: Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
 Catalin Marinas <Catalin.Marinas@arm.com>
Cc: nd <nd@arm.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
 "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
 "linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Will Deacon <Will.Deacon@arm.com>, Andrey Konovalov <andreyknvl@google.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190612142111.28161-1-vincenzo.frascino@arm.com>
 <20190612142111.28161-2-vincenzo.frascino@arm.com>
 <a90da586-8ff6-4bed-d940-9306d517a18c@arm.com>
 <20190613092054.GO28951@C02TF0J2HF1T.local>
 <dee7f192-d0f0-558e-3007-eba805c6f2da@arm.com>
 <6ebbda37-5dd9-d0d5-d9cb-286c7a5b7f8e@arm.com>
 <8e3c9537-de10-0d0d-f5bb-c33bde92443f@arm.com>
 <5963d144-be9b-78d8-9130-ef92bc66b1fd@arm.com>
 <ba822b33-a822-02ef-9b85-725f4353596a@arm.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <a05a2dfb-3398-455d-8586-b79dfb7a772f@arm.com>
Date: Thu, 13 Jun 2019 16:35:35 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <ba822b33-a822-02ef-9b85-725f4353596a@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 13/06/2019 16:32, Szabolcs Nagy wrote:
> On 13/06/2019 15:03, Vincenzo Frascino wrote:
>> On 13/06/2019 13:28, Szabolcs Nagy wrote:
>>> On 13/06/2019 12:16, Vincenzo Frascino wrote:
>>>> On 13/06/2019 11:14, Szabolcs Nagy wrote:
>>>>> On 13/06/2019 10:20, Catalin Marinas wrote:
>>>>>> On Wed, Jun 12, 2019 at 05:30:34PM +0100, Szabolcs Nagy wrote:
>>>>>>> On 12/06/2019 15:21, Vincenzo Frascino wrote:
>>>>>>>> +  - a mapping below sbrk(0) done by the process itself
>>>>>>>
>>>>>>> doesn't the mmap rule cover this?
>>>>>>
>>>>>> IIUC it doesn't cover it as that's memory mapped by the kernel
>>>>>> automatically on access vs a pointer returned by mmap(). The statement
>>>>>> above talks about how the address is obtained by the user.
>>>>>
>>>>> ok i read 'mapping below sbrk' as an mmap (possibly MAP_FIXED)
>>>>> that happens to be below the heap area.
>>>>>
>>>>> i think "below sbrk(0)" is not the best term to use: there
>>>>> may be address range below the heap area that can be mmapped
>>>>> and thus below sbrk(0) and sbrk is a posix api not a linux
>>>>> syscall, the libc can implement it with mmap or whatever.
>>>>>
>>>>> i'm not sure what the right term for 'heap area' is
>>>>> (the address range between syscall(__NR_brk,0) at
>>>>> program startup and its current value?)
>>>>>
>>>>
>>>> I used sbrk(0) with the meaning of "end of the process's data segment" not
>>>> implying that this is a syscall, but just as a useful way to identify the mapping.
>>>> I agree that it is a posix function implemented by libc but when it is used with
>>>> 0 finds the current location of the program break, which can be changed by brk()
>>>> and depending on the new address passed to this syscall can have the effect of
>>>> allocating or deallocating memory.
>>>>
>>>> Will changing sbrk(0) with "end of the process's data segment" make it more clear?
>>>
>>> i don't understand what's the relevance of the *end*
>>> of the data segment.
>>>
>>> i'd expect the text to say something about the address
>>> range of the data segment.
>>>
>>> i can do
>>>
>>> mmap((void*)65536, 65536, PROT_READ|PROT_WRITE, MAP_FIXED|MAP_SHARED|MAP_ANON, -1, 0);
>>>
>>> and it will be below the end of the data segment.
>>>
>>
>> As far as I understand the data segment "lives" below the program break, hence
>> it is a way of describing the range from which the user can obtain a valid
>> tagged pointer.>
>> Said that, I am not really sure on how do you want me to document this (my aim
>> is for this to be clear to the userspace developers). Could you please propose
>> something?
> 
> [...], it is in the memory ranges privately owned by a
> userspace process and it is obtained in one of the
> following ways:
> 
> - mmap done by the process itself, [...]
> 
> - brk syscall done by the process itself.
>   (i.e. the heap area between the initial location
>   of the program break at process creation and its
>   current location.)
> 
> - any memory mapped by the kernel [...]
> 
> the data segment that's part of the process image is
> already covered by the last point.
> 

Thanks Szabolcs, I will update the document accordingly.

-- 
Regards,
Vincenzo

