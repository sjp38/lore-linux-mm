Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16B7FC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:09:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA7A620823
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:09:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA7A620823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 880E86B0006; Thu, 28 Mar 2019 11:09:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 831D66B0007; Thu, 28 Mar 2019 11:09:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FAD86B0008; Thu, 28 Mar 2019 11:09:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8F66B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:09:22 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id d139so1466489qke.20
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:09:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ub9FmRgi+EHYVXyrizDtesz838zjhS5zOTRmO7yQeOA=;
        b=EohNPiF17eDExCnZqP71+jURYv3tOH6bWWSyvTfoeb9TMhtdV110L10cIKAwCzh3l4
         /itjpy4QYYS+4amnu+n5yGnl2fnzB078g6H5cIHcy44F9VGjYjRKsDxjDM6pI7hTTOGJ
         ymNl9ncf+F+7Q80kH0mxI+9iGsfKcNbXWTWvEgqqerGK/OX9C6u9ACdTPOHtoNf9+ikd
         gCRFVz+gqXArltzYKqDNd9pd3MlE509AfUyyAgSk553XYxbrnl6ACRa+BCDc8DWuGUbg
         9KZZHklgi9azjyO29A5MgoTxJw4abHCuuMOguM0rkep2l31cY1xpbgIAD2Yj51d4NGn9
         tZLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUUL7C0Txu2D+AVBMX9AvwPI6WsZLAzZe9+5JhsVPpzfvflVeCL
	/SO0J4ePA1AEJc++b4BW2yTLgjq/4Dv+ucJQB9FjrUleDiBGeD+eviPVUp4b5h3i1TS9GVntc6a
	4db0JXehxZF/UuEKJCK7udKPgd/wyh0YYVMixv999pTqlLiNL24U/wrAktIWa9GI7bQ==
X-Received: by 2002:a0c:86f5:: with SMTP id 50mr34414434qvg.70.1553785761878;
        Thu, 28 Mar 2019 08:09:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBKjX3L4rMOCmAu162zKEy1Rbt8C5QO91Ybjpm0oW8boo0ZfQ9DsL8/gx42a1Az+oVzAXV
X-Received: by 2002:a0c:86f5:: with SMTP id 50mr34414366qvg.70.1553785760947;
        Thu, 28 Mar 2019 08:09:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553785760; cv=none;
        d=google.com; s=arc-20160816;
        b=0cXT4+sbXVFjGlukg3GmnWnc1vsSKofOZhLszTJa/ud9mfOMGs+OHFvSKiEdsnaRNo
         RTQKysH9BWLOsEa1Qw5iD8xeCEyR1HECX/t643yzJ/74eiKWPzxMjua7OLwHOG+5ZkWi
         CbkawMScYyw0Syw/LUpsLB27vKis+vuT7XJQs6PpLhgjLJ8TnekVCmrjR+KuReFsY7YP
         nDxXeBvhqu7syWTuvm4HDqVIF+0y5IJvDyACgKybtHqzCJDsTGNx3/wdeLnPc7D+UC2m
         +be7578rrtHT8/b5ni9SXsMHAgc/vzQKkPdLGvVOrX/9MCLuO0LQq/VSQYkqcDEGPjYL
         LlHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=ub9FmRgi+EHYVXyrizDtesz838zjhS5zOTRmO7yQeOA=;
        b=O528LwxV+KS4/3W/npEPZd407YJPjN97vP1CtxGFcXkqp+PwfV2i0UeP1YelJOkMF+
         Si4mHo0kt0F5izimkBZ6ztsqCY3TBofz2rzsJ7dtfSZj/pKpbsir3bHO/BQc9NrVM6GU
         yu6VMbsztxlsbFpZBQU+TOtkQ+yOWBa43HHZ/TlvW1mnjL3swOJVUB8YncDXqltgkMuS
         cOmGtz32ORdAoNJTSMRG4wTrdtm1SmhcyiD0h1iPiZn6XCDtde5f72Hvx1UpH3FaZsHA
         KUKus10ZJmuuqY4NpR8oFFfYiOr4uyzsIlxZpR2DuvBc05iyeCllB06QNpttZ6qA2mjL
         0X0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h19si4584560qto.168.2019.03.28.08.09.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 08:09:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 110383078A2E;
	Thu, 28 Mar 2019 15:09:10 +0000 (UTC)
Received: from [10.36.117.191] (ovpn-117-191.ams2.redhat.com [10.36.117.191])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 50D8ED1C6;
	Thu, 28 Mar 2019 15:09:07 +0000 (UTC)
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
 anshuman.khandual@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190328134320.13232-1-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
Date: Thu, 28 Mar 2019 16:09:06 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190328134320.13232-1-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 28 Mar 2019 15:09:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28.03.19 14:43, Oscar Salvador wrote:
> Hi,
> 
> since last two RFCs were almost unnoticed (thanks David for the feedback),
> I decided to re-work some parts to make it more simple and give it a more
> testing, and drop the RFC, to see if it gets more attention.
> I also added David's feedback, so now all users of add_memory/__add_memory/
> add_memory_resource can specify whether they want to use this feature or not.

Terrific, I will also definetly try to make use of that in the next
virito-mem prototype (looks like I'll finally have time to look into it
again).

> I also fixed some compilation issues when CONFIG_SPARSEMEM_VMEMMAP is not set.
> 
> [Testing]
> 
> Testing has been carried out on the following platforms:
> 
>  - x86_64 (small and big memblocks)
>  - powerpc
>  - arm64 (Huawei's fellows)
> 
> I plan to test it on Xen and Hyper-V, but for now those two will not be
> using this feature, and neither DAX/pmem.

I think doing it step by step is the right approach. Less likely to
break stuff.

> 
> Of course, if this does not find any strong objection, my next step is to
> work on enabling this on Xen/Hyper-V.
> 
> [Coverletter]
> 
> This is another step to make the memory hotplug more usable. The primary
> goal of this patchset is to reduce memory overhead of the hot added
> memory (at least for SPARSE_VMEMMAP memory model). The current way we use
> to populate memmap (struct page array) has two main drawbacks:
> 
> a) it consumes an additional memory until the hotadded memory itself is
>    onlined and
> b) memmap might end up on a different numa node which is especially true
>    for movable_node configuration.
> 
> a) is problem especially for memory hotplug based memory "ballooning"
>    solutions when the delay between physical memory hotplug and the
>    onlining can lead to OOM and that led to introduction of hacks like auto
>    onlining (see 31bc3858ea3e ("memory-hotplug: add automatic onlining
>    policy for the newly added memory")).
> 
> b) can have performance drawbacks.
> 
> I have also seen hot-add operations failing on archs because they
> were running out of order-x pages.
> E.g On powerpc, in certain configurations, we use order-8 pages,
> and given 64KB base pagesize, that is 16MB.
> If we run out of those, we just fail the operation and we cannot add
> more memory.
> We could fallback to base pages as x86_64 does, but we can do better.
> 
> One way to mitigate all these issues is to simply allocate memmap array
> (which is the largest memory footprint of the physical memory hotplug)
> from the hotadded memory itself. VMEMMAP memory model allows us to map
> any pfn range so the memory doesn't need to be online to be usable
> for the array. See patch 3 for more details. In short I am reusing an
> existing vmem_altmap which wants to achieve the same thing for nvdim
> device memory.
> 
> There is also one potential drawback, though. If somebody uses memory
> hotplug for 1G (gigantic) hugetlb pages then this scheme will not work
> for them obviously because each memory block will contain reserved
> area. Large x86 machines will use 2G memblocks so at least one 1G page
> will be available but this is still not 2G...
> 
> If that is a problem, we can always configure a fallback strategy to
> use the current scheme.
> 
> Since this only works when CONFIG_VMEMMAP_ENABLED is set,
> we do check for it before setting the flag that allows use
> to use the feature, no matter if the user wanted it.
> 
> [Overall design]:
> 
> Let us say we hot-add 2GB of memory on a x86_64 (memblock size = 128M).
> That is:
> 
>  - 16 sections
>  - 524288 pages
>  - 8192 vmemmap pages (out of those 524288. We spend 512 pages for each section)
> 
>  The range of pages is: 0xffffea0004000000 - 0xffffea0006000000
>  The vmemmap range is:  0xffffea0004000000 - 0xffffea0004080000
> 
>  0xffffea0004000000 is the head vmemmap page (first page), while all the others
>  are "tails".
> 
>  We keep the following information in it:
> 
>  - Head page:
>    - head->_refcount: number of sections
>    - head->private :  number of vmemmap pages
>  - Tail page:
>    - tail->freelist : pointer to the head
> 
> This is done because it eases the work in cases where we have to compute the
> number of vmemmap pages to know how much do we have to skip etc, and to keep
> the right accounting to present_pages.
> 
> When we want to hot-remove the range, we need to be careful because the first
> pages of that range, are used for the memmap maping, so if we remove those
> first, we would blow up while accessing the others later on.
> For that reason we keep the number of sections in head->_refcount, to know how
> much do we have to defer the free up.
> 
> Since in a hot-remove operation, sections are being removed sequentially, the
> approach taken here is that every time we hit free_section_memmap(), we decrease
> the refcount of the head.
> When it reaches 0, we know that we hit the last section, so we call
> vmemmap_free() for the whole memory-range in backwards, so we make sure that
> the pages used for the mapping will be latest to be freed up.
> 
> Vmemmap pages are charged to spanned/present_paged, but not to manages_pages.
> 

I guess one important thing to mention is that it is no longer possible
to remove memory in a different granularity it was added. I slightly
remember that ACPI code sometimes "reuses" parts of already added
memory. We would have to validate that this can indeed not be an issue.

drivers/acpi/acpi_memhotplug.c:

result = __add_memory(node, info->start_addr, info->length);
if (result && result != -EEXIST)
	continue;

What would happen when removing this dimm (->remove_memory())


Also have a look at

arch/powerpc/platforms/powernv/memtrace.c

I consider it evil code. It will simply try to offline+unplug *some*
memory it finds in *some granularity*. Not sure if this might be
problematic-

Would there be any "safety net" for adding/removing memory in different
granularities?

-- 

Thanks,

David / dhildenb

