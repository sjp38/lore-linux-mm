Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71B42C282C4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:34:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13203222BE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:34:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ozlabs-ru.20150623.gappssmtp.com header.i=@ozlabs-ru.20150623.gappssmtp.com header.b="oB6g38EZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13203222BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ozlabs.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8250C8E0002; Tue, 12 Feb 2019 19:34:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D4768E0001; Tue, 12 Feb 2019 19:34:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 675D38E0002; Tue, 12 Feb 2019 19:34:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 20D3B8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 19:34:40 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id w20so433454ply.16
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:34:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=Y7soHirDIxJzFUwQJpcgzxlvKe2FQs1FDN0wHWCHK3k=;
        b=WeF8V8nUwEhEVtRYTSQM3BZG0dop/gpplyUlguLReq/HFNzpSxNglMj/b5JwvnO2U7
         x1SZt0BCxoxBlNG4p9lKzLITQuOBMP4zFnnpAEushhJxHmWYi+TtqBbj+qDDSuOneWuz
         vlVltO9+WWYMPyNJ8JjfTmIxJCgb9m2iX04h8GwaOqh0zw00M8MTil6wFEvgRkXI8LEJ
         WglXd5G7aU5bqnXmaJIx8ai5d3Vvg+nHbU1b0uM4t3BqCFfRo1CDGSW8yIUIf51XaeO8
         rbALwLf1zinhUxY7uA4FrwA9OrDtcoErITN59V40dPJz6WhnxAmo4WqEW50cJDxdSZOP
         Entg==
X-Gm-Message-State: AHQUAuYMOk90FhKUdSeyS/rKojYHFeJfD4LGTP8YgLXil84zu17ukxXL
	0hFHfPQyXJ24J+kBkWzNWCDMssIhsMSKwJFd+PSImZcuGtvU63I+Vi7gP2QlDERKGhThPYAyl4q
	wsaqt8UkUBr3qYp06rcvyGPPaUeeb5jyq1VyXLUGsIP1R1yArXB72kWVM68rzuF9n5Gc1w6SiKl
	2ro67a3QaaGzDXVz2T1k4mKHwMMpddtFFpnL5wFGKRFujl4WOwDkCT4uV9a+RrfZuVdUnXPO1gv
	fmE0x+LB6Em3IZNkkfz/xVw/Adit9fHsVHQ8Yr6dVdtMQIYdDnhHtzrP3M7gvAKuQbRsVWiKarO
	62ET9muWD0kycg2pId3LxDOVkQtlfzQNsG8rMpeloghY6K/uKQlpAceQcIZz97uQX3SU2L+nZWu
	a
X-Received: by 2002:a17:902:8bc6:: with SMTP id r6mr6746012plo.67.1550018079757;
        Tue, 12 Feb 2019 16:34:39 -0800 (PST)
X-Received: by 2002:a17:902:8bc6:: with SMTP id r6mr6745950plo.67.1550018078870;
        Tue, 12 Feb 2019 16:34:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550018078; cv=none;
        d=google.com; s=arc-20160816;
        b=kIN85h4V0YS96pxYRZd5nznVmbEiEJgSfWFbiCVkO97+t+Yi6jYkyhN8JQiNBwJvbI
         zdd3Vczn66o+TmsbZCzxPMY1vMZVNQXLw3LQy9XICPZ02dv0lzqdK/9X7+UyOVtcgFg4
         S4RiNL9ujF0tIyUW8PILlRSwSJ4GiZxRTQ+sEyNQBrUdyez/u6993b6Z49lchBBWV+0S
         txJA5Bcgy1loUQI0ty0e5qC0/e0fw/PQi7hlDOL99lHOdJrLvjWcFxHXIzX/lgsR/1xz
         qs+kSxiMMpS7GQzBz6MkvuNd5AZ/Ng5zEuKHMxKW8Qspdy+L7YJFhpSaYxR4OHaZS0bv
         m/wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=Y7soHirDIxJzFUwQJpcgzxlvKe2FQs1FDN0wHWCHK3k=;
        b=za0gh/28a35te4WUzCCoMllnWXj3k9QL9E6eHKXp0eKZ1cwRu3IW/c7/4kMsZ+OuOR
         n93BglM6D9AR9hCUaYt7yMfXNjw6H3wHd6CZdwstKDjbaKrFavrGgaX9K/HI7veC0C7u
         jlrIl4L1tAuJkSZHPsHdoShsa0PttFXR4CotV4/0Uq83qjcry2fCgqqBRjLlwFvkjNlT
         P4ZP34JvpE53rAmLZmRWPEO9zFF/PQOpiW7ACLTlqEIgge6TjVyrgSAom1VSX6q15nKd
         EPyBodYRGHAgXVoZzY/n0jfbSW+KMJO/Hkt58trkrtPz2izW6/giS75BwLYK/KmQk3FR
         b4MQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ozlabs-ru.20150623.gappssmtp.com header.s=20150623 header.b=oB6g38EZ;
       spf=pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) smtp.mailfrom=aik@ozlabs.ru
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7sor15160435plm.11.2019.02.12.16.34.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 16:34:38 -0800 (PST)
Received-SPF: pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ozlabs-ru.20150623.gappssmtp.com header.s=20150623 header.b=oB6g38EZ;
       spf=pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) smtp.mailfrom=aik@ozlabs.ru
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ozlabs-ru.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:openpgp:autocrypt:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Y7soHirDIxJzFUwQJpcgzxlvKe2FQs1FDN0wHWCHK3k=;
        b=oB6g38EZU2d7cL7oss7W1n2/HbtMMRe3ua88W4xCbhDHHoZuBzPCRCS6RoXSYCGdyc
         AEneiZUfmZUIlw6kdAmu+bEGtw9jqzeYqXfsiGPqSptM0ErHXydatt7ynmSO44HyU8zD
         Pxpsht/pARmU1BdZaYwJO6bjisS+hUCDTljZLIfEvF15SX2+Yg9dI4AYY9tEbJeFoj7f
         qy1FzPVXbOLJKZNOI4NqFJyijIffV8GHiDzsYc3tyF8P+k+Xf06sLRjNio2ysr0/G3fK
         hVaUGmitDjNjkDK1WDEQ4DCC5tJRvpRGTSVHtGTKZW/IRYX52WIeoVttWCAkupH5AYgw
         X74A==
X-Google-Smtp-Source: AHgI3IZRXfZvVsKAozcEImmEcLoKJrECcL3CZDyV/bGzlgnvh+eqOI4O0Vpl9kGos9lLojWXmFfGrw==
X-Received: by 2002:a17:902:4025:: with SMTP id b34mr6863042pld.181.1550018078090;
        Tue, 12 Feb 2019 16:34:38 -0800 (PST)
Received: from [10.61.2.175] ([122.99.82.10])
        by smtp.gmail.com with ESMTPSA id f67sm19836025pff.29.2019.02.12.16.34.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 16:34:37 -0800 (PST)
Subject: Re: [PATCH 2/5] vfio/spapr_tce: use pinned_vm instead of locked_vm to
 account pinned pages
To: Alex Williamson <alex.williamson@redhat.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, jgg@ziepe.ca,
 akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz, cl@linux.com,
 linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
 linux-kernel@vger.kernel.org, paulus@ozlabs.org, benh@kernel.crashing.org,
 mpe@ellerman.id.au, hao.wu@intel.com, atull@kernel.org, mdf@kernel.org
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211224437.25267-3-daniel.m.jordan@oracle.com>
 <ee4d14db-05c3-6208-503c-16e287fa78eb@ozlabs.ru>
 <20190212115652.6cf9a20b@w520.home>
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Openpgp: preference=signencrypt
Autocrypt: addr=aik@ozlabs.ru; keydata=
 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
Message-ID: <5e478ac6-814d-d599-e44f-5e90232d30b3@ozlabs.ru>
Date: Wed, 13 Feb 2019 11:34:28 +1100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190212115652.6cf9a20b@w520.home>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 13/02/2019 05:56, Alex Williamson wrote:
> On Tue, 12 Feb 2019 17:56:18 +1100
> Alexey Kardashevskiy <aik@ozlabs.ru> wrote:
> 
>> On 12/02/2019 09:44, Daniel Jordan wrote:
>>> Beginning with bc3e53f682d9 ("mm: distinguish between mlocked and pinned
>>> pages"), locked and pinned pages are accounted separately.  The SPAPR
>>> TCE VFIO IOMMU driver accounts pinned pages to locked_vm; use pinned_vm
>>> instead.
>>>
>>> pinned_vm recently became atomic and so no longer relies on mmap_sem
>>> held as writer: delete.
>>>
>>> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
>>> ---
>>>  Documentation/vfio.txt              |  6 +--
>>>  drivers/vfio/vfio_iommu_spapr_tce.c | 64 ++++++++++++++---------------
>>>  2 files changed, 33 insertions(+), 37 deletions(-)
>>>
>>> diff --git a/Documentation/vfio.txt b/Documentation/vfio.txt
>>> index f1a4d3c3ba0b..fa37d65363f9 100644
>>> --- a/Documentation/vfio.txt
>>> +++ b/Documentation/vfio.txt
>>> @@ -308,7 +308,7 @@ This implementation has some specifics:
>>>     currently there is no way to reduce the number of calls. In order to make
>>>     things faster, the map/unmap handling has been implemented in real mode
>>>     which provides an excellent performance which has limitations such as
>>> -   inability to do locked pages accounting in real time.
>>> +   inability to do pinned pages accounting in real time.
>>>  
>>>  4) According to sPAPR specification, A Partitionable Endpoint (PE) is an I/O
>>>     subtree that can be treated as a unit for the purposes of partitioning and
>>> @@ -324,7 +324,7 @@ This implementation has some specifics:
>>>  		returns the size and the start of the DMA window on the PCI bus.
>>>  
>>>  	VFIO_IOMMU_ENABLE
>>> -		enables the container. The locked pages accounting
>>> +		enables the container. The pinned pages accounting
>>>  		is done at this point. This lets user first to know what
>>>  		the DMA window is and adjust rlimit before doing any real job.
> 
> I don't know of a ulimit only covering pinned pages, so for
> documentation it seems more correct to continue referring to this as
> locked page accounting.
> 
>>> @@ -454,7 +454,7 @@ This implementation has some specifics:
>>>  
>>>     PPC64 paravirtualized guests generate a lot of map/unmap requests,
>>>     and the handling of those includes pinning/unpinning pages and updating
>>> -   mm::locked_vm counter to make sure we do not exceed the rlimit.
>>> +   mm::pinned_vm counter to make sure we do not exceed the rlimit.
>>>     The v2 IOMMU splits accounting and pinning into separate operations:
>>>  
>>>     - VFIO_IOMMU_SPAPR_REGISTER_MEMORY/VFIO_IOMMU_SPAPR_UNREGISTER_MEMORY ioctls
>>> diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
>>> index c424913324e3..f47e020dc5e4 100644
>>> --- a/drivers/vfio/vfio_iommu_spapr_tce.c
>>> +++ b/drivers/vfio/vfio_iommu_spapr_tce.c
>>> @@ -34,9 +34,11 @@
>>>  static void tce_iommu_detach_group(void *iommu_data,
>>>  		struct iommu_group *iommu_group);
>>>  
>>> -static long try_increment_locked_vm(struct mm_struct *mm, long npages)
>>> +static long try_increment_pinned_vm(struct mm_struct *mm, long npages)
>>>  {
>>> -	long ret = 0, locked, lock_limit;
>>> +	long ret = 0;
>>> +	s64 pinned;
>>> +	unsigned long lock_limit;
>>>  
>>>  	if (WARN_ON_ONCE(!mm))
>>>  		return -EPERM;
>>> @@ -44,39 +46,33 @@ static long try_increment_locked_vm(struct mm_struct *mm, long npages)
>>>  	if (!npages)
>>>  		return 0;
>>>  
>>> -	down_write(&mm->mmap_sem);
>>> -	locked = mm->locked_vm + npages;
>>> +	pinned = atomic64_add_return(npages, &mm->pinned_vm);
>>>  	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>>> -	if (locked > lock_limit && !capable(CAP_IPC_LOCK))
>>> +	if (pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
>>>  		ret = -ENOMEM;
>>> -	else
>>> -		mm->locked_vm += npages;
>>> +		atomic64_sub(npages, &mm->pinned_vm);
>>> +	}
>>>  
>>> -	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %ld/%ld%s\n", current->pid,
>>> +	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %ld/%lu%s\n", current->pid,
>>>  			npages << PAGE_SHIFT,
>>> -			mm->locked_vm << PAGE_SHIFT,
>>> -			rlimit(RLIMIT_MEMLOCK),
>>> -			ret ? " - exceeded" : "");
>>> -
>>> -	up_write(&mm->mmap_sem);
>>> +			atomic64_read(&mm->pinned_vm) << PAGE_SHIFT,
>>> +			rlimit(RLIMIT_MEMLOCK), ret ? " - exceeded" : "");
>>>  
>>>  	return ret;
>>>  }
>>>  
>>> -static void decrement_locked_vm(struct mm_struct *mm, long npages)
>>> +static void decrement_pinned_vm(struct mm_struct *mm, long npages)
>>>  {
>>>  	if (!mm || !npages)
>>>  		return;
>>>  
>>> -	down_write(&mm->mmap_sem);
>>> -	if (WARN_ON_ONCE(npages > mm->locked_vm))
>>> -		npages = mm->locked_vm;
>>> -	mm->locked_vm -= npages;
>>> -	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %ld/%ld\n", current->pid,
>>> +	if (WARN_ON_ONCE(npages > atomic64_read(&mm->pinned_vm)))
>>> +		npages = atomic64_read(&mm->pinned_vm);
>>> +	atomic64_sub(npages, &mm->pinned_vm);
>>> +	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %ld/%lu\n", current->pid,
>>>  			npages << PAGE_SHIFT,
>>> -			mm->locked_vm << PAGE_SHIFT,
>>> +			atomic64_read(&mm->pinned_vm) << PAGE_SHIFT,
>>>  			rlimit(RLIMIT_MEMLOCK));
>>> -	up_write(&mm->mmap_sem);  
>>
>>
>> So it used to be down_write+up_write and stuff in between.
>>
>> Now it is 3 independent accesses (actually 4 but the last one is
>> diagnostic) with no locking around them. Why do not we need a lock
>> anymore precisely? Thanks,
> 
> The first 2 look pretty sketchy to me, is there a case where you don't
> know how many pages you've pinned to unpin them?

No case like this, this is why WARN_ON_ONCE(). At the time I could have
been under impression that pinned_vm is system-global, hence that
adjustment but we do not really need it there.

>  And can it ever
> really be correct to just unpin whatever remains?  The last access is
> diagnostic, which leaves 1.  Daniel's rework to warn on a negative
> result looks more sane. Thanks,

Yes it does look sane.


-- 
Alexey

