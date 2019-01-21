Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68E23C282DB
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 08:06:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E46320823
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 08:06:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="d3iRdJ/V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E46320823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFB6E8E0024; Mon, 21 Jan 2019 03:06:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAB2F8E0018; Mon, 21 Jan 2019 03:06:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC50C8E0024; Mon, 21 Jan 2019 03:06:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE058E0018
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:06:07 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id 201so10910404ywp.13
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:06:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:references:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=p32sQDI6ox884rw5fGb9+nzl0KtF9Y6AnqZiwtU2mA8=;
        b=KQwiGOoL6uFHXzTU/CmQWtNMEAp9dkC57COu/9fo/4/fCyDXbBNneq+LfEVCqMk1SH
         BA4f1BM7wgYVl7CvoFqYo18laUG0Md8IBdfaGRbZdOuPHaR0sXU16qBpKYCPkldaiWKY
         EQMnvKksovOzr8N6ZM2UmsiOoCbl3h/NcW3eNjFF8wrN6V01fpPCnfnU7oAYGl2hoaPw
         8Y6ZCDQnde2VpAPE76+TjJUc+1VW6L+KLlcX/Z5oqJyVjS204hK2lYz2RhhL55SSXOIX
         YpqPsGHf21tBIuyL1dNkm1KONZ5NN6+3FtiuuQs4NTVvuudsHe6z8JTv+Zdt4tg8Tn3G
         izgw==
X-Gm-Message-State: AJcUukcu6aRnsklJu2ijGCx0uZFLSn910ZcL6xHLoVRcSOOS+A1bAcr+
	WbNHd8q3R4DPhrvI1Dc9Md2bV+bAihAeSovcCeemV7T3YBYYrYN9VVpmXy8buz89wGGljweHDCJ
	G3GdRvABDhNOjFnzxHGm80YO0Gc4PgXMdKa95qSsFTsGeC7mTals+5Ng5LK2MViwIXA==
X-Received: by 2002:a81:2c09:: with SMTP id s9mr27089267yws.165.1548057967265;
        Mon, 21 Jan 2019 00:06:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN65bwhTrMfoHmhuFuigFrwnyAQ/HqHFKY7ZIbsK6ysXJcn2hSste/TABV7pOtNL3496cGo1
X-Received: by 2002:a81:2c09:: with SMTP id s9mr27089236yws.165.1548057966545;
        Mon, 21 Jan 2019 00:06:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548057966; cv=none;
        d=google.com; s=arc-20160816;
        b=pW94ibwoeRA2MGYR6MvjsnCntr6PWmoHpBM2aBZmj0TBH/GNCxuujw0Ex0LHvLmkwD
         4u2Eei7+zMGNCv3pzONJjOHwAUTCLUXZxMDI02pt3TH9aVrQA4VVRBrMMdQwxAPB5Dep
         QQDv7diVE5BRzslfFGjBOIWEA64U8wlJUkFX3E1OEvzk3Lhp/HB+vKD0aviVSrb7gu6i
         y8bDk2hBuB417iTALUTWZQtrt3U8KqbsAA8FO5DU3DRZYw9mvUZwToOob97FpTa/rJqp
         HOWFEol/XHwUFJpH0RWpTt8DX2xirdYCVQiLx6fqpCSjh2GH+sTYdMW8Dsi+2wE6arxP
         bD5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:references:cc
         :to:from:subject;
        bh=p32sQDI6ox884rw5fGb9+nzl0KtF9Y6AnqZiwtU2mA8=;
        b=X0Gyx6+0/QWU8/mJK2xLL2KCjk3/u6GhDVzP0ToQvGYYqkkuQ6B6MTFLIPXe+MHsUu
         c9BZeeLTpePPqYlKyITRE/MnOYddkDjQaY+CaYm/Eukp7ZLlGJJbZa51+6SCw9orOzV/
         i1+es4CvX65pN1VFwDpiFR3gX+wRBVekFNwHrn1yVpAX6Av41EOqK/VWDyglQghO/ilH
         PEZHTgL2AXVzXhGh2RrMcsA+zPdujWnUTocgOYH/Uks7IPJ8V56aVAE3Y9noNwaMTvgw
         FYcgAIHGMOhkBn0BaqedIaqn+8MRyrr4+5vESLE86apobOmuOu8IVBE+0I+hzs/7BL9+
         O2nw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="d3iRdJ/V";
       spf=pass (google.com: domain of amhetre@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=amhetre@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id g129si8607877ywh.259.2019.01.21.00.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 00:06:06 -0800 (PST)
Received-SPF: pass (google.com: domain of amhetre@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="d3iRdJ/V";
       spf=pass (google.com: domain of amhetre@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=amhetre@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c457d4c0000>; Mon, 21 Jan 2019 00:05:32 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 21 Jan 2019 00:06:05 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 21 Jan 2019 00:06:05 -0800
Received: from [10.24.229.42] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 21 Jan
 2019 08:06:01 +0000
Subject: Re: [PATCH] mm: Expose lazy vfree pages to control via sysctl
From: Ashish Mhetre <amhetre@nvidia.com>
To: Matthew Wilcox <willy@infradead.org>
CC: <vdumpa@nvidia.com>, <mcgrof@kernel.org>, <keescook@chromium.org>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<linux-tegra@vger.kernel.org>, <Snikam@nvidia.com>, <avanbrunt@nvidia.com>
References: <1546616141-486-1-git-send-email-amhetre@nvidia.com>
 <20190104180332.GV6310@bombadil.infradead.org>
 <a7bb656a-c815-09a4-69fc-bb9e7427cfa6@nvidia.com>
Message-ID: <27bd8776-87fa-69ad-7b6e-4425251b5e9c@nvidia.com>
Date: Mon, 21 Jan 2019 13:36:00 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <a7bb656a-c815-09a4-69fc-bb9e7427cfa6@nvidia.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"; format="flowed"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1548057932; bh=p32sQDI6ox884rw5fGb9+nzl0KtF9Y6AnqZiwtU2mA8=;
	h=X-PGP-Universal:Subject:From:To:CC:References:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=d3iRdJ/VYyrOLckotFMOUko9EC56GYaN0i/ItutV3lHntwGMBRttdbgRwSmFk+NES
	 fnK3hwBKifXG25nNbbFX81U9mUwQyadFr8T8rgfhmiczRHofAg3oSkMm9NnReu5Y4t
	 Zy4jRTWcsIssJsJbHHCd6iD/acCI4tqtgGwf2yZfeGum0S93gjQPiLEVtJdoSQhnff
	 NPZUvA58krZT0fid46WvtW3VoQ4qCGc/act+rZIQswuYjdxzvemRV4BDTqKGXAouMD
	 LtW8IkH60KKO9EKWzyWryfIDIAhnf+gAWF4yxj9Gl0sVQFtKWtwZQZd+S38QZxSrmj
	 4TnaQnFoADiXA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121080600.zz3E156j9qghfw85l9HrSyigYnCU7-GdTId1yTG0FEw@z>

The issue is not seen on new kernel. This patch won't be needed. Thanks.

On 06/01/19 2:12 PM, Ashish Mhetre wrote:
> Matthew, this issue was last reported in September 2018 on K4.9.
> I verified that the optimization patches mentioned by you were not=20
> present in our downstream kernel when we faced the issue. I will check=20
> whether issue still persist on new kernel with all these patches and=20
> come back.
>=20
> On 04/01/19 11:33 PM, Matthew Wilcox wrote:
>> On Fri, Jan 04, 2019 at 09:05:41PM +0530, Ashish Mhetre wrote:
>>> From: Hiroshi Doyu <hdoyu@nvidia.com>
>>>
>>> The purpose of lazy_max_pages is to gather virtual address space till i=
t
>>> reaches the lazy_max_pages limit and then purge with a TLB flush and=20
>>> hence
>>> reduce the number of global TLB flushes.
>>> The default value of lazy_max_pages with one CPU is 32MB and with 4=20
>>> CPUs it
>>> is 96MB i.e. for 4 cores, 96MB of vmalloc space will be gathered=20
>>> before it
>>> is purged with a TLB flush.
>>> This feature has shown random latency issues. For example, we have seen
>>> that the kernel thread for some camera application spent 30ms in
>>> __purge_vmap_area_lazy() with 4 CPUs.
>>
>> You're not the first to report something like this.=C2=A0 Looking throug=
h the
>> kernel logs, I see:
>>
>> commit 763b218ddfaf56761c19923beb7e16656f66ec62
>> Author: Joel Fernandes <joelaf@google.com>
>> Date:=C2=A0=C2=A0 Mon Dec 12 16:44:26 2016 -0800
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0 mm: add preempt points into __purge_vmap_area_l=
azy()
>>
>> commit f9e09977671b618aeb25ddc0d4c9a84d5b5cde9d
>> Author: Christoph Hellwig <hch@lst.de>
>> Date:=C2=A0=C2=A0 Mon Dec 12 16:44:23 2016 -0800
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0 mm: turn vmap_purge_lock into a mutex
>>
>> commit 80c4bd7a5e4368b680e0aeb57050a1b06eb573d8
>> Author: Chris Wilson <chris@chris-wilson.co.uk>
>> Date:=C2=A0=C2=A0 Fri May 20 16:57:38 2016 -0700
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0 mm/vmalloc: keep a separate lazy-free list
>>
>> So the first thing I want to do is to confirm that you see this problem
>> on a modern kernel.=C2=A0 We've had trouble with NVidia before reporting
>> historical problems as if they were new.
>>

