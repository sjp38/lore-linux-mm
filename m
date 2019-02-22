Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B7D4C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 14:12:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22D38206B7
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 14:12:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22D38206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A31718E010D; Fri, 22 Feb 2019 09:12:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E0F78E0109; Fri, 22 Feb 2019 09:12:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A84C8E010D; Fri, 22 Feb 2019 09:12:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1FA8E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 09:12:18 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id b6so1607404qkg.4
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 06:12:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:reply-to
         :subject:references:to:cc:from:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding;
        bh=70IeNMGv9bVYgBQiOSgo2GSk5LjWHRMltVvShjCHCJw=;
        b=HPVuFRCI7t4kg8ka3bqiTUKf05sHSOlWqoVS4FRyP0ujdalj47qIduAPxxuN+E6iFU
         Cro9h/pqg3FUA88xolFhvID8aWwRJGId9/AkyO6oQ5rHYXb+CBQbD5SwNp06QTD9VL4H
         v2Z/k8+XkQlAS8aqRD6HngOVGxTmMnSukCFIQwY516NEF0zRspu2JSHlfpQ3+SgXN5c/
         an1IlVKFIzxfjyqlmofYY9rY172rDsuE8WXg2QkyvtAR6wAXTRh8woUtNhkA4HfNbrxn
         q3qmbpOrfX1GbC+PneWBnOsiCL4Ckp53Rsm/r45i1mrf0HZtm7Ku9PZo7fYyw+IO2zam
         ruQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lwoodman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lwoodman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYFQNCNiV3UgpGlVig9/xQTbyVV5yoII8Gj6KhFKU0HdInuwF0o
	sG0RSmz54x/ClrOmXkkiOtr48rw8/TYj0GQ+2/croozbusnob53/rZrYI506sxso8ijGUtUplJn
	P+twBYhAfNZBmeq2ErNaQp86eSlBVY4W7Wl4J6XbS+WQMOzTVo43gHDdkOU8DoCoqRQ==
X-Received: by 2002:a0c:891a:: with SMTP id 26mr3282798qvp.163.1550844738169;
        Fri, 22 Feb 2019 06:12:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ0FypdP+Bzl1m/46SKIB/FsjLnHzXiIefWcxr1nfe2roo32BMR2b6eRCVg54M6j810maer
X-Received: by 2002:a0c:891a:: with SMTP id 26mr3282761qvp.163.1550844737447;
        Fri, 22 Feb 2019 06:12:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550844737; cv=none;
        d=google.com; s=arc-20160816;
        b=ENHAsqD7V3+xfH0qf2MGxpDdM96iOlSHiOVu1rXcNDsJqpLlXh97dEl4IwULZa83/h
         +V/oRRhlY04i0s4m6zc37gn3dmIJKCGp07s3psvNWn4Cu/Iy/D5IgUERfJ/YUEV29/0K
         tqCsvVArwtqnnrHqMVfGAE3E1DJpwVjrkG/pmfNh0NvnGDaS7g4j9sUJXfRKiD7lSK/U
         cDItN9XOFUlWW/29X6KFboq/whxbMDkUOxC/cF5sEZAH4wGF/MT7X57GJWrX1OZ0noXg
         itvwro4iB7sjWy6sgcov4ABf70AZrfWST69VNK0fEukbeO4lxrIaC8Hppi7TlpAAYOYi
         DpsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:organization:from:cc:to:references:subject:reply-to;
        bh=70IeNMGv9bVYgBQiOSgo2GSk5LjWHRMltVvShjCHCJw=;
        b=vnjwZucoH1iIa/AkF3z5t01qtjwnLeUeauFZXeuhjQUyZnsqGUVJJ0yifOcWewryG3
         gStcuekp76ZFB6mEbkR77GVGU9+lbgHdUvvqyz6bbhmH/AkLUnCOLOlC0Y39NTwm7oS2
         HpP9MUaAouuZ3BPwRq6Y/zQLZ9AszYSvo7whGHxXbN1FaSGTtBNm/uhyhYDwbO0ZH5Lk
         i7rpcMtMkY3YCMSFBfaftfg2hv8pRSkP8Fax8SGjHre5xpS77DcurbFQo03T/iTJ5USU
         Nip4ZrocKT+haf/atj8msrykWeaY7BCYVe/zqRER1RiuQ3Y1TzPeh+jzM9/XRvElerkF
         x4qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lwoodman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lwoodman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a63si1035697qke.67.2019.02.22.06.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 06:12:17 -0800 (PST)
Received-SPF: pass (google.com: domain of lwoodman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lwoodman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lwoodman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A2E2DA70E;
	Fri, 22 Feb 2019 14:12:16 +0000 (UTC)
Received: from lwoodman.boston.csb (ovpn-124-89.rdu2.redhat.com [10.10.124.89])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EE0AE5D704;
	Fri, 22 Feb 2019 14:12:15 +0000 (UTC)
Reply-To: lwoodman@redhat.com
Subject: Re: [LSF/MM ATTEND ] memory reclaim with NUMA rebalancing
References: <20190130174847.GD18811@dhcp22.suse.cz>
 <87h8dpnwxg.fsf@linux.ibm.com>
 <01000168c431dbc5-65c68c0c-e853-4dda-9eef-8a9346834e59-000000@email.amazonses.com>
To: Christopher Lameter <cl@linux.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org,
 linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>,
 linux-nvme@lists.infradead.org
From: Larry Woodman <lwoodman@redhat.com>
Organization: Red Hat
Message-ID: <d491fcc4-97c1-168e-e1c5-1106ea77f080@redhat.com>
Date: Fri, 22 Feb 2019 09:12:15 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101
 Thunderbird/45.8.0
MIME-Version: 1.0
In-Reply-To: <01000168c431dbc5-65c68c0c-e853-4dda-9eef-8a9346834e59-000000@email.amazonses.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 22 Feb 2019 14:12:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/06/2019 02:03 PM, Christopher Lameter wrote:
> On Thu, 31 Jan 2019, Aneesh Kumar K.V wrote:
>
>> I would be interested in this topic too. I would like to
>> understand the API and how it can help exploit the different type of
>> devices we have on OpenCAPI.
Same here, we/RedHat have quite a bit of experience running on several
large system
(32TB/128nodes/1024CPUs).  Some of these systems have NVRAM and can operated
in memory mode as well as storage mode.

Larry

> So am I. We may want to rethink the whole NUMA API and the way we handle
> different types of memory with their divergent performance
> characteristics.
>
> We need some way to allow a better selection of memory from the kernel
> without creating too much complexity. We have new characteristics to
> cover:
>
> 1. Persistence (NVRAM) or generally a storage device that allows access to
>    the medium via a RAM like interface.
>
> 2. Coprocessor memory that can be shuffled back and forth to a device
>    (HMM).
>
> 3. On Device memory (important since PCIe limitations are currently a
>    problem and Intel is stuck on PCIe3 and devices start to bypass the
>    processor to gain performance)
>
> 4. High Density RAM (GDDR f.e.) with different caching behavior
>    and/or different cacheline sizes.
>
> 5. Modifying access characteristics by reserving slice of a cache (f.e.
>    L3) for a specific memory region.
>
> 6. SRAM support (high speed memory on the processor itself or by using
>    the processor cache to persist a cacheline)
>
> And then the old NUMA stuff where only the latency to memory varies. But
> that was a particular solution targeted at scaling SMP system through
> interconnects. This was a mostly symmetric approach. The use of
> accellerators etc etc and the above characteristics lead to more complex
> assymmetric memory approaches that may be difficult to manage and use from
> kernel space.
>

