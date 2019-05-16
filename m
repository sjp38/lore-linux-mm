Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 204B4C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 14:25:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D072320833
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 14:25:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D072320833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60B156B0006; Thu, 16 May 2019 10:25:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BB5A6B0007; Thu, 16 May 2019 10:25:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AAD16B0008; Thu, 16 May 2019 10:25:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id DAC506B0006
	for <linux-mm@kvack.org>; Thu, 16 May 2019 10:25:10 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id q29so718163lfb.11
        for <linux-mm@kvack.org>; Thu, 16 May 2019 07:25:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BHIpC+UdANUov3s0HHM/ibRe8plH32u/8iUjr4VOiDw=;
        b=s9wxpecDPt97XWRvgEJJ8OWrzUqjD+VrlIF0L7uWpAS0fMkwXe6WHWhU2rNkhDrXT3
         5X96UJ6bsEyRq51YX0kU7qD53yt2SNiciHm2Ix0kg9BRc5aA9ZzntWaGq5+YPbC6AXbB
         vKkmwZ2mp1Qs3dioQm/9yQWXXPIf+9SlvaK28Lb+fGWNljHj0pAwJfYw/3T/FjBgseOJ
         sREqeiYiLuT2+EY090qc8UQcQ7ugpXc/dA8dFnxRJlGBwRuvGzMcUxtlMRzHrJ3V2TB1
         o/UOo79NlZ/EPas+6vXJuFSV1ghd+VMucLIzzeorANQZEUuq5xFK/tFZaAY4EoOjVi19
         MHEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXWe590bbAB+E+uMZUWTVrA4Wk9DKhtnZW42vJPXtl5Hyitf8GW
	+NEsae351TysvsEjih6K8q7ZBLQ3Fh9Xjr12loaFvgd+woxpiHaroK0a7PgGbNE2+lu+hz2/hqM
	rKoamVitCI+edWqU9CX46g5/cBAJ9EYz8/XekTod2gTUijwYuUIqMeHlaTSq+9+ffWg==
X-Received: by 2002:a2e:980f:: with SMTP id a15mr24437821ljj.131.1558016710318;
        Thu, 16 May 2019 07:25:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOZnHA5xN98r7dPApBBtVAASQ7g43i1/2i2VPYdhlNVGQgrRhicx0Cqx5xG7V5xOIsa95v
X-Received: by 2002:a2e:980f:: with SMTP id a15mr24437771ljj.131.1558016709546;
        Thu, 16 May 2019 07:25:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558016709; cv=none;
        d=google.com; s=arc-20160816;
        b=b3GqZfWAM+SEYFoTIZWaE8rahjRM+dBnKhZkmuQmsu022DbSZgKwKwtgYG/7xPjUz9
         5KlaBOYvkfQD+3Yxt57Mox5RzpbI7+KrfbgOnku/0H+cRSJVH6NrwkFVCt4iIoBTwoyy
         Uv7aQ8rz7JOCMlfS/BsmVwGHkKFEKA/4vBMaZWdFt0XeBKqt5qd67qoXEWD88MP6CVtB
         4G6GfeqQRAy4/DXEMUBcSC9Ag4fKAxmbff89B0PMQK2JWHTTQnu1GxY2ksvsSUOnnTuQ
         wAP+7VVHXQ5oxcrav+BZ690ABGE7ou2ZJUAgpasOw8UfpJqnjmCq8i4KvcTbnoolm0NA
         88CQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=BHIpC+UdANUov3s0HHM/ibRe8plH32u/8iUjr4VOiDw=;
        b=ahqQ+wQEyqdX+RKzGLkhwOV4XKAqbCXeH4Sdr0iLxDZQmzCjV45WKT2Owj1V4PnjFb
         H2SuyWCgLZaDDo/06e1u2hWNYHbw3+hlFi4ucbvxLBz7eMCOIlMdQg+CHZYwgMaGvaUA
         BS6JdhTZKSBUS+vE4kY1UspB7hNZ3TgJXLGcOrkUhisT8Rc3OH5uudqQy+RISKirbQVM
         QOEN2jWfCOG+MSTYICXps6Ir2EcM/4HxLiMeHVrp6C4h/KU7jM8TsVnvTB5cjk9DyB/e
         gp8ZRMjubSUNnNWt80iD1BR41wafdr9C82ZeI7lA5YcrBwcx2/KcnPgLYw3lXXA+OB/Z
         PlTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id p17si4624006ljp.141.2019.05.16.07.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 07:25:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hRHJj-0007J4-HM; Thu, 16 May 2019 17:25:07 +0300
Subject: Re: [PATCH RFC 0/5] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
To: Adam Borowski <kilobyte@angband.pl>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com,
 keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 pasha.tatashin@oracle.com, alexander.h.duyck@linux.intel.com,
 ira.weiny@intel.com, andreyknvl@google.com, arunks@codeaurora.org,
 vbabka@suse.cz, cl@linux.com, riel@surriel.com, keescook@chromium.org,
 hannes@cmpxchg.org, npiggin@gmail.com, mathieu.desnoyers@efficios.com,
 shakeelb@google.com, guro@fb.com, aarcange@redhat.com, hughd@google.com,
 jglisse@redhat.com, mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
 <20190515193841.GA29728@angband.pl>
 <7136aa47-3ce5-243d-6c92-5893b7b1379d@virtuozzo.com>
 <20190516134220.GB24860@angband.pl>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <14efd2c5-ffd1-84ad-b1d1-42f8ef44d7e2@virtuozzo.com>
Date: Thu, 16 May 2019 17:25:06 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190516134220.GB24860@angband.pl>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 16.05.2019 16:42, Adam Borowski wrote:
> On Thu, May 16, 2019 at 04:10:07PM +0300, Kirill Tkhai wrote:
>> On 15.05.2019 22:38, Adam Borowski wrote:
>>> On Wed, May 15, 2019 at 06:11:15PM +0300, Kirill Tkhai wrote:
>>>> This patchset adds a new syscall, which makes possible
>>>> to clone a mapping from a process to another process.
>>>> The syscall supplements the functionality provided
>>>> by process_vm_writev() and process_vm_readv() syscalls,
>>>> and it may be useful in many situation.
>>>>
>>>> For example, it allows to make a zero copy of data,
>>>> when process_vm_writev() was previously used:
>>>
>>> I wonder, why not optimize the existing interfaces to do zero copy if
>>> properly aligned?  No need for a new syscall, and old code would immediately
>>> benefit.
>>
>> Because, this is just not possible. You can't zero copy anonymous pages
>> of a process to pages of a remote process, when they are different pages.
> 
> fork() manages that, and so does KSM.  Like KSM, you want to make a page
> shared -- you just skip the comparison step as you want to overwrite the old
> contents.
> 
> And there's no need to touch the page, as fork() manages that fine no matter
> if the page is resident, anonymous in swap, or file-backed, all without
> reading from swap.

Yes, and in case of you dive into the patchset, you will found the new syscall
manages page table entries in the same way fork() makes.
 
>>>> There are several problems with process_vm_writev() in this example:
>>>>
>>>> 1)it causes pagefault on remote process memory, and it forces
>>>>   allocation of a new page (if was not preallocated);
>>>>
>>>> 2)amount of memory for this example is doubled in a moment --
>>>>   n pages in current and n pages in remote tasks are occupied
>>>>   at the same time;
>>>>
>>>> 3)received data has no a chance to be properly swapped for
>>>>   a long time.
>>>
>>> That'll handle all of your above problems, except for making pages
>>> subject to CoW if written to.  But if making pages writeably shared is
>>> desired, the old functions have a "flags" argument that doesn't yet have a
>>> single bit defined.
> 
> 
> Meow!
> 

