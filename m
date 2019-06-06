Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99866C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 21:17:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CBDE208C0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 21:17:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="eWiauVwq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CBDE208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC53B6B02E1; Thu,  6 Jun 2019 17:17:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B76596B02E3; Thu,  6 Jun 2019 17:17:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A167A6B02E5; Thu,  6 Jun 2019 17:17:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 759406B02E1
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 17:17:30 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id w5so1133695oig.18
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 14:17:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=i4pH9SKagiR96nYXZvFJhe68v+83LBSdVRAblgIAYAQ=;
        b=UYYnENJHdo66OwZUIVNUVfiU7ZOBVcWmdEldgWBnkGC+1jvlgY1bsPJFdbpm/kFgM2
         fBZ0H2L/Ipy/E/zA3J6scmWawD1234bFC/Np62WJt8sRU6jo5C1XfgoP4gmqtxUSeYUr
         h+zFu5zeB16nFAInhK/7kN2GcUuJjhE0a2H4J5ajmJHZRmJDng4UtYCkxbsx2+T4TNr0
         5Ch44iRsZ4Pjg4bVG+yyPwoswGjytGq682/LQU2KrOAo726idsZdp6cC/D6uRYu6PKGy
         U0/FxmM0cvLJ6ICOkkKnIxXy2VnCrbQr7LRUllwfsDAI/U7NMDYEnCLG/MbGebbrsSM5
         b6XA==
X-Gm-Message-State: APjAAAVYNRSKYZcFRtkVjXXWjTICDPtrevz3SZFkbcP7iOsSPVDEIoNL
	SseQl7zGjqhAvlMg8GsyMpSO3PtlL0wG+1odieXe0uElLwjVkOP67zzEd3wVAAnMC2uU2omzaiY
	3N9T/h8hSWWzS/4l1NGOHCr5yeA+XsGprSPwPy4edoZB66notZE8SO8X3mcNOs26s9Q==
X-Received: by 2002:aca:4343:: with SMTP id q64mr1548413oia.82.1559855850088;
        Thu, 06 Jun 2019 14:17:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwy41OHCzUX2IptKUv8mys+VlymkBwup9UTRSNcui7om+k9YtWLqjzQokc67fMlKqYLQbS6
X-Received: by 2002:aca:4343:: with SMTP id q64mr1548364oia.82.1559855849168;
        Thu, 06 Jun 2019 14:17:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559855849; cv=none;
        d=google.com; s=arc-20160816;
        b=bU5QSotho4WG378kRGE1DN+JLmvyTWs3v8X74gmMkUmAgSs16r5PFY9PxBWW2zruN5
         SwUZGtKU69j5jOg03IoOAz1mb3GPayAJEgHNn7I6tobtJK4JSwudbdJYPNl0XCm4oLVI
         bBSt7nKOArau+beBPLlUZej5oebbyTcWH1f880eXp++BhR2C7JXgaw6WgTS1ZlsYwQTF
         5AbH3vL7AblBZ1uahY4mr9LFdJla2NGKi6mcQirgY8Gm5CKuaEcv2Z5E9V1bTWTLI6RI
         4kCZXnjDVJcx4adg0oiwKPwGTfr/TUyrHe8NUleXMDLMe3MXgmrrBrpGxnfRR4jDjkFp
         RfdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=i4pH9SKagiR96nYXZvFJhe68v+83LBSdVRAblgIAYAQ=;
        b=mY8TFdBomUOaIbtvz4IfTY4K98r438B1zYMlDbo0JDJtnnyKxAOl/d61W66I1N3Oux
         tUBj1ZvM4EDtv0H0Od6vEXrSkT5h3TMLknkkbiTzDY8GJGjDRez74zH8CH1An2DKvxOM
         5w+VW8RFN3+q0tUi0Fh36FLVRSjWwq0UuIf4M+iSkdgi6BvHkyyXY8f2uvH7xZS8rBcI
         1n1v4oWOS2su4QINtQL5OqxJxTXJFG7wgD5lrDT1rJlEhiN/WBGiLEiwd7a4Z9+6HA52
         6yNXGgISVovY+eMDxPWyOhl86KPjX7iAR4Qn126ctyjGg8uQDYezGbM4HOgT3Ws2S3Be
         hGUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=eWiauVwq;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id n68si5343ota.269.2019.06.06.14.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 14:17:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=eWiauVwq;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf982d90000>; Thu, 06 Jun 2019 14:17:13 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 14:17:28 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 06 Jun 2019 14:17:28 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 6 Jun
 2019 21:17:28 +0000
Subject: Re: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
To: Pingfan Liu <kernelfans@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>
CC: <linux-mm@kvack.org>, Ira Weiny <ira.weiny@intel.com>, Mike Rapoport
	<rppt@linux.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox
	<willy@infradead.org>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Keith
 Busch <keith.busch@intel.com>, Christoph Hellwig <hch@infradead.org>, LKML
	<linux-kernel@vger.kernel.org>
References: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
 <20190605144912.f0059d4bd13c563ddb37877e@linux-foundation.org>
 <CAFgQCTur5ReVHm6NHdbD3wWM5WOiAzhfEXdLnBGRdZtf7q1HFw@mail.gmail.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <2b0a65ec-4fb0-430e-3e6a-b713fb5bb28f@nvidia.com>
Date: Thu, 6 Jun 2019 14:17:27 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAFgQCTur5ReVHm6NHdbD3wWM5WOiAzhfEXdLnBGRdZtf7q1HFw@mail.gmail.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559855833; bh=i4pH9SKagiR96nYXZvFJhe68v+83LBSdVRAblgIAYAQ=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=eWiauVwq0cMfiC+QWs/85Nu4AYyu9WBcaT9+nM7L4eJTcuQRIGndhJQ42mqfms1/9
	 jCEjjS5YttMJxXs+7oRKyxg9pb5S9QKIWK1fRhRcH91ElVE5j4eZ//HwuJcLuXy6+p
	 FlUOTA6w8i52KHohYHxouBe+st8Cl8DZHopYTyqGBVv9EwhBGYW5lWHyhiOVVtjT9Q
	 Ojrf8iZNwwtIBVr4SJ2WIwOVwv9aW/ra5hC1CIG3Ok1r7jPewYoEvnNW0oDnLyeUXA
	 T+9vkZY2Yb6ho1Lmsh4QCLUEDe+W0MaPWHL8+U2o3/GD7HpbV/d7sCNU9ZbBQKA2Ia
	 6u6h4TX4pSUwQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/5/19 7:19 PM, Pingfan Liu wrote:
> On Thu, Jun 6, 2019 at 5:49 AM Andrew Morton <akpm@linux-foundation.org> wrote:
...
>>> --- a/mm/gup.c
>>> +++ b/mm/gup.c
>>> @@ -2196,6 +2196,26 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
>>>       return ret;
>>>  }
>>>
>>> +#ifdef CONFIG_CMA
>>> +static inline int reject_cma_pages(int nr_pinned, struct page **pages)
>>> +{
>>> +     int i;
>>> +
>>> +     for (i = 0; i < nr_pinned; i++)
>>> +             if (is_migrate_cma_page(pages[i])) {
>>> +                     put_user_pages(pages + i, nr_pinned - i);
>>> +                     return i;
>>> +             }
>>> +
>>> +     return nr_pinned;
>>> +}
>>
>> There's no point in inlining this.
> OK, will drop it in V4.
> 
>>
>> The code seems inefficient.  If it encounters a single CMA page it can
>> end up discarding a possibly significant number of non-CMA pages.  I
> The trick is the page is not be discarded, in fact, they are still be
> referrenced by pte. We just leave the slow path to pick up the non-CMA
> pages again.
> 
>> guess that doesn't matter much, as get_user_pages(FOLL_LONGTERM) is
>> rare.  But could we avoid this (and the second pass across pages[]) by
>> checking for a CMA page within gup_pte_range()?
> It will spread the same logic to hugetlb pte and normal pte. And no
> improvement in performance due to slow path. So I think maybe it is
> not worth.
> 
>>

I think the concern is: for the successful gup_fast case with no CMA
pages, this patch is adding another complete loop through all the 
pages. In the fast case.

If the check were instead done as part of the gup_pte_range(), then
it would be a little more efficient for that case.

As for whether it's worth it, *probably* this is too small an effect to measure. 
But in order to attempt a measurement: running fio (https://github.com/axboe/fio)
with O_DIRECT on an NVMe drive, might shed some light. Here's an fio.conf file 
that Jan Kara and Tom Talpey helped me come up with, for related testing:

[reader]
direct=1
ioengine=libaio
blocksize=4096
size=1g
numjobs=1
rw=read
iodepth=64



thanks,
-- 
John Hubbard
NVIDIA

