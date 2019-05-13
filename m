Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 154C6C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 17:23:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0F642084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 17:23:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="S6jaG8Ep"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0F642084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 007AB6B0005; Mon, 13 May 2019 13:23:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAC256B0008; Mon, 13 May 2019 13:23:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFD856B0010; Mon, 13 May 2019 13:23:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 914656B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 13:23:30 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j18so9991583pfi.20
        for <linux-mm@kvack.org>; Mon, 13 May 2019 10:23:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=n8vpRjGW5GPHF+IO0n302JSczsEWtzgDfOElD0ZndA8=;
        b=bPjPYi42hC54ZkAn7Mb7p5X3M1/Qlxjf2y6wumMB62W7Hdet8ekf/ILRnVEytDzvZ8
         X3hDKiaGFGOctTTq22hMusdUL+hUdpLbrGb4gvd+/jY5207EgnYzh9cQzsJEWkQ01JAs
         J1uTaJTm27SQILmH39rqmsW0RqCsaJv+OICpm0L1zkrvucsu1+Yqp5DeeS6J3oA0lXnM
         fTWLEa44rwyA64IKeGDr92AqPGokCp1p87aVzfIksEMvmVFkvOJjBscChCX5HaPeDxPO
         tniZ5B+6w/mZv+cosR+dX7gS7O+DbtY0fIHKuTiOFQRYBi7it5oDSgBIR5pWerlbjfZ5
         irxA==
X-Gm-Message-State: APjAAAWo8gmtp6V6E4IaCjzJEo6p8MDFq1t+MG9T9lmnMZGtimdRr59b
	EyOmn0iM/ZdOujLDvcP3Mx6eYgEM6M3XRjeNhtwyyRrswb4s2pO4aBvW77dXiLoCe2HU2dPtEk+
	2kAeE460u6+2LpE5bqbiUYYxlokMH3TNHJVkqH3WCTOjUEjMFeB/K7w7ByjY5Tl2x2A==
X-Received: by 2002:a63:5443:: with SMTP id e3mr32284298pgm.265.1557768210105;
        Mon, 13 May 2019 10:23:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKEfZ+aVbVQhSwDDLV5Ci3bLipac3qSA0bdCS7Cw/fz6Va5DblvRKEBCDIVfd7N+vWljbt
X-Received: by 2002:a63:5443:: with SMTP id e3mr32284195pgm.265.1557768209084;
        Mon, 13 May 2019 10:23:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557768209; cv=none;
        d=google.com; s=arc-20160816;
        b=sgxdofw6BTAIYNTV5rnowgZDXigbYrWKp089HHe3P3laKv2s7vPlwRCWH7fpXHE9SR
         gShxeToarLHQCWCI0uLBzThEN7q0r6p0dVOlMti8ZetRkxFRWj9+jBWSBGNuC5+WcBY/
         FrSYygJLMZ3ZGyF2NBkM8BAL5kr+MJU48VuRcKCiXkZ/2ixGD0GoaRu+/zlTXT/Gu2Pu
         MUp7GVbu3iBDuXzXY4jYdpe6HwAayXPDm04VbxwUxeKVtnVExORgLTcDElFI1eMKFAwM
         VdJoZKryoxRPG8UmTO7HklAw5un669/WiaVL4eLBWvEzLB/c7GvqaTz9H9jhnLOmJ9ff
         q3gQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=n8vpRjGW5GPHF+IO0n302JSczsEWtzgDfOElD0ZndA8=;
        b=u33S0cUQYD2CnsjTCz5jSK3N7SrXFqjeW4LsiljJEbewKgAiz8bPOVBclySQl5iyYw
         98TU1b/cf+PwPuavULUiZrUf/ED3Hmq4+nIm9HYMMDCVRNEvTS0v4mY4La7ntx6A9qBn
         dEsvzwARXCgaJ8wSLMb1dePQ6SP01lXsijJZlkgexNDr9TWKiFLCl35Tb3AktXiO4JRE
         uhEJdfpoEm8tCHlgR5vKbkIi/9vbq8XX/fmfJjreSi2X2XR0MHQjFl8zxANP2nMPdOnH
         QwffFmWReneJrleuJXXfADw89xz7pSpDTpTDojJBb3icJB8+7YnL9zkmIyVNVTxv86a9
         pMDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=S6jaG8Ep;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id j15si9644456pgs.43.2019.05.13.10.23.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 10:23:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=S6jaG8Ep;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cd9a7e90000>; Mon, 13 May 2019 10:22:49 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 13 May 2019 10:23:28 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 13 May 2019 10:23:28 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 13 May
 2019 17:23:28 +0000
Subject: Re: [PATCH 4/5] mm/hmm: hmm_vma_fault() doesn't always call
 hmm_range_unregister()
To: Jerome Glisse <jglisse@redhat.com>
CC: Souptick Joarder <jrdr.linux@gmail.com>, Linux-MM <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, Ira Weiny
	<ira.weiny@intel.com>, Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann
	<arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Dan Carpenter
	<dan.carpenter@oracle.com>, Matthew Wilcox <willy@infradead.org>, Andrew
 Morton <akpm@linux-foundation.org>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-5-rcampbell@nvidia.com>
 <CAFqt6zbhLQuw2N5-=Nma-vHz1BkWjviOttRsPXmde8U1Oocz0Q@mail.gmail.com>
 <fa2078fd-3ec7-5503-94d7-c4d1a766029a@nvidia.com>
 <20190512150724.GA4238@redhat.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <43d3eab0-acf9-e823-8b62-6e692e7b6ec5@nvidia.com>
Date: Mon, 13 May 2019 10:23:27 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190512150724.GA4238@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1557768169; bh=n8vpRjGW5GPHF+IO0n302JSczsEWtzgDfOElD0ZndA8=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=S6jaG8EpUHqREXnq/w6qes8gG0EhywAaS9pjrQa5P3fPTjRND/mXesGNWHI5zh5lS
	 MCAZhXIcQpxJz2UIHCdK1sL59SAJWTaEu7ZDnUT2d0A8dqAI/XxT4Yv+Y1wfM4y7Ql
	 JccyVUf0+urKTYCR3NG8sQn3XcNnn+f4txkkgZaL4DuBd1beY4b9uS0DRS58ifa2ZY
	 mEisv1qr0a8+ZfeXUTn/EvHyMtY1tPBgXuqwLTlWXICwW1Xru8PS3DUf6guSMS+nQF
	 dN/t4rnbMWPqrllLWmMx/goWpph2WFgLe9x6Hcm4NXGbdH5b7Kneot0A4EmuKA/Juh
	 J2mWd5McJixXg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/12/19 8:07 AM, Jerome Glisse wrote:
> On Tue, May 07, 2019 at 11:12:14AM -0700, Ralph Campbell wrote:
>>
>> On 5/7/19 6:15 AM, Souptick Joarder wrote:
>>> On Tue, May 7, 2019 at 5:00 AM <rcampbell@nvidia.com> wrote:
>>>>
>>>> From: Ralph Campbell <rcampbell@nvidia.com>
>>>>
>>>> The helper function hmm_vma_fault() calls hmm_range_register() but is
>>>> missing a call to hmm_range_unregister() in one of the error paths.
>>>> This leads to a reference count leak and ultimately a memory leak on
>>>> struct hmm.
>>>>
>>>> Always call hmm_range_unregister() if hmm_range_register() succeeded.
>>>
>>> How about * Call hmm_range_unregister() in error path if
>>> hmm_range_register() succeeded* ?
>>
>> Sure, sounds good.
>> I'll include that in v2.
> 
> NAK for the patch see below why
> 
>>
>>>>
>>>> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
>>>> Cc: John Hubbard <jhubbard@nvidia.com>
>>>> Cc: Ira Weiny <ira.weiny@intel.com>
>>>> Cc: Dan Williams <dan.j.williams@intel.com>
>>>> Cc: Arnd Bergmann <arnd@arndb.de>
>>>> Cc: Balbir Singh <bsingharora@gmail.com>
>>>> Cc: Dan Carpenter <dan.carpenter@oracle.com>
>>>> Cc: Matthew Wilcox <willy@infradead.org>
>>>> Cc: Souptick Joarder <jrdr.linux@gmail.com>
>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>>> ---
>>>>    include/linux/hmm.h | 3 ++-
>>>>    1 file changed, 2 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
>>>> index 35a429621e1e..fa0671d67269 100644
>>>> --- a/include/linux/hmm.h
>>>> +++ b/include/linux/hmm.h
>>>> @@ -559,6 +559,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
>>>>                   return (int)ret;
>>>>
>>>>           if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
>>>> +               hmm_range_unregister(range);
>>>>                   /*
>>>>                    * The mmap_sem was taken by driver we release it here and
>>>>                    * returns -EAGAIN which correspond to mmap_sem have been
>>>> @@ -570,13 +571,13 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
>>>>
>>>>           ret = hmm_range_fault(range, block);
>>>>           if (ret <= 0) {
>>>> +               hmm_range_unregister(range);
>>>
>>> what is the reason to moved it up ?
>>
>> I moved it up because the normal calling pattern is:
>>      down_read(&mm->mmap_sem)
>>      hmm_vma_fault()
>>          hmm_range_register()
>>          hmm_range_fault()
>>          hmm_range_unregister()
>>      up_read(&mm->mmap_sem)
>>
>> I don't think it is a bug to unlock mmap_sem and then unregister,
>> it is just more consistent nesting.
> 
> So this is not the usage pattern with HMM usage pattern is:
> 
> hmm_range_register()
> hmm_range_fault()
> hmm_range_unregister()
> 
> The hmm_vma_fault() is gonne so this patch here break thing.
> 
> See https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-5.2-v3

The patch series is on top of v5.1-rc6-mmotm-2019-04-25-16-30.
hmm_vma_fault() is defined there and in your hmm-5.2-v3 branch as
a backward compatibility transition function in include/linux/hmm.h.
So I agree the new API is to use hmm_range_register(), etc.
This is intended to cover the transition period.
Note that hmm_vma_fault() is being called from
drivers/gpu/drm/nouveau/nouveau_svm.c in both trees.

