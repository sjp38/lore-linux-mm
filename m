Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6167C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:35:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6037D2084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:35:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6037D2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F04886B0005; Thu, 20 Jun 2019 12:35:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB57C8E0003; Thu, 20 Jun 2019 12:35:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7C6C8E0001; Thu, 20 Jun 2019 12:35:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id B61956B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:35:58 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v4so4312031qkj.10
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 09:35:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=+v82EA19QUdGg0HujII6g3ea1F/gqFFo2+aBUrf6nSQ=;
        b=Cgjumdm+ajQWw4QyibkzZQeWOG59T/6vCgblBEf5W/mYmAHQxKxPIhqv7pbJP+xfXc
         bwuz1w/15A7wBwAUSUSBUflX5UKYP2JpjZySW16g5YVoDTGv3JX51jK5ucJk8H/gVffl
         KON8iZVDi9kjbNo8knRY6WUmLMQY2d41jnFv5bo/TnqUIgwgrw5P7511Qs2dPpYBRuUr
         HEEGEb/u1Uw0zPcQwdOe07Dt+cQp2Kg9Fq4YSr2BGffrz6fHu0AN4vmqA95IBUMcKCcB
         AM09dEqSdrRXpo9Dozo6WL3XsFDfHTjwucZZwrvhsjKRKOFVzIrk8y3zHohGdTOmdhGA
         TMZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXKZ6l/xAqM0KhNcv1Ty26HXaPlCqaAI8qoPuZvdsOJpgZgDYuy
	H7GOkuuCM4L/ZPOEtBwv2TC+E7ZfQGOKT5QhGR3BehvLXAAahvydVRfFtwmHXpOVtaqW79Q1ZN9
	Q0dsnC/IvUuIVerV7DGOCRrPVhmtGj/wOKMqcJGcPrFYFSeyqyqjIKFNjzzTeZ1JfCA==
X-Received: by 2002:a05:620a:1519:: with SMTP id i25mr12027472qkk.331.1561048558490;
        Thu, 20 Jun 2019 09:35:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzW+ZsfQ8UaW3BLH1OEYtj8taQcdx/EnphzHLL5qaMxeGSSNoiqARXuTt59Tg/lHWzZpnz8
X-Received: by 2002:a05:620a:1519:: with SMTP id i25mr12027423qkk.331.1561048557927;
        Thu, 20 Jun 2019 09:35:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561048557; cv=none;
        d=google.com; s=arc-20160816;
        b=mICIN8i95ffZzWxCu2D8oYeOrSFXUPyKMoXkv/l/8080yP432hlsfVyL6Kth91YKOb
         mVT0AZO4jh+0gXlbeCbwojRg8nXDiVcTrT2O1eBoaOg9iSHEmR3C81XC0dtcY9qzCca5
         fbVDHEyVvh27PRWGYOFJj+MczUNWRGSJr5whIcJsX4zEFNmrXaCw+gh2eqvceSCApqJN
         mHel89d73IdLvuz1rSZXDND8ZG3wIFFsGxUdCOJTe8Dz3mzxW9FcB1wmwnyHLJ+vZeYe
         +XbzNLNBP0ZHLsFScthinvP/50TezRtBTYA6SlGQTDtYAXHrxtQAswvPAF4wgLrJBYzM
         gszA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=+v82EA19QUdGg0HujII6g3ea1F/gqFFo2+aBUrf6nSQ=;
        b=NSJymVL8tL+S9tRt1bR5uvwbj9ryN24Pjz/BCQ58M8zEElcib0qRitsq/aorLwjPCg
         SSMFUI82wlxXSQGammwUoAANyMVnJqnUmAF8ArQCbHsJ5E4eHOqj/UJJyzP25e4wxE6r
         wImDpL9PlOUkEJIF0fopyUjhVGSP1q0Nxd7XSen2bWO6HBdrqj1b0tz/toOYTgpj0AR3
         TdHceTuLEayK1JupkGB0lemY2FoP5XbxmytzApq7DDVp5MzP7YwnBa8MbTXT/ZptGyCS
         ufo2oG9cNTJF74qvVsk6XoHN1VTDw3O8Zh69QNm8gZOsgxwV29pNVMhfXKu0B4MtpbA7
         bUgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f28si10481246qkh.113.2019.06.20.09.35.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 09:35:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1024731628F5;
	Thu, 20 Jun 2019 16:35:57 +0000 (UTC)
Received: from [10.36.116.54] (ovpn-116-54.ams2.redhat.com [10.36.116.54])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E491D60BE0;
	Thu, 20 Jun 2019 16:35:54 +0000 (UTC)
Subject: Re: [PATCH v10 08/13] mm/sparsemem: Prepare for sub-section ranges
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko
 <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, Linux MM <linux-mm@kvack.org>,
 linux-nvdimm <linux-nvdimm@lists.01.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
 <156092353780.979959.9713046515562743194.stgit@dwillia2-desk3.amr.corp.intel.com>
 <70f3559b-2832-67eb-0715-ed9f856f6ed9@redhat.com>
 <CAPcyv4jzELzrf-p6ujUwdXN2FRe0WCNhpTziP2-z4-8uBSSp7A@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <d62e1f2f-70db-da84-5cc3-01fab779aeb7@redhat.com>
Date: Thu, 20 Jun 2019 18:35:54 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jzELzrf-p6ujUwdXN2FRe0WCNhpTziP2-z4-8uBSSp7A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 20 Jun 2019 16:35:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 20.06.19 18:19, Dan Williams wrote:
> On Thu, Jun 20, 2019 at 3:31 AM David Hildenbrand <david@redhat.com> wrote:
>>
>> On 19.06.19 07:52, Dan Williams wrote:
>>> Prepare the memory hot-{add,remove} paths for handling sub-section
>>> ranges by plumbing the starting page frame and number of pages being
>>> handled through arch_{add,remove}_memory() to
>>> sparse_{add,remove}_one_section().
>>>
>>> This is simply plumbing, small cleanups, and some identifier renames. No
>>> intended functional changes.
>>>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Vlastimil Babka <vbabka@suse.cz>
>>> Cc: Logan Gunthorpe <logang@deltatee.com>
>>> Cc: Oscar Salvador <osalvador@suse.de>
>>> Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
>>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>>> ---
>>>  include/linux/memory_hotplug.h |    5 +-
>>>  mm/memory_hotplug.c            |  114 +++++++++++++++++++++++++---------------
>>>  mm/sparse.c                    |   16 ++----
>>>  3 files changed, 81 insertions(+), 54 deletions(-)
> [..]
>>> @@ -528,31 +556,31 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
>>>   * sure that pages are marked reserved and zones are adjust properly by
>>>   * calling offline_pages().
>>>   */
>>> -void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>>> +void __remove_pages(struct zone *zone, unsigned long pfn,
>>>                   unsigned long nr_pages, struct vmem_altmap *altmap)
>>>  {
>>> -     unsigned long i;
>>>       unsigned long map_offset = 0;
>>> -     int sections_to_remove;
>>> +     int i, start_sec, end_sec;
>>
>> As mentioned in v9, use "unsigned long" for start_sec and end_sec please.
> 
> Honestly I saw you and Andrew going back and forth about "unsigned
> long i" that I thought this would be handled by a follow on patchset
> when that debate settled.
> 

I'll send a fixup then, once this patch set is final - hoping I won't
forget about it (that's why I asked about using these types in the first
place).

-- 

Thanks,

David / dhildenb

