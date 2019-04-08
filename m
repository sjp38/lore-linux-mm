Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E738C282DD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 06:03:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD03420870
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 06:03:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD03420870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A5CD6B0287; Mon,  8 Apr 2019 02:03:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52E036B0288; Mon,  8 Apr 2019 02:03:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F59A6B0289; Mon,  8 Apr 2019 02:03:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E2F786B0287
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 02:03:42 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w27so6317913edb.13
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 23:03:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=duMszPrz3cQunSb4kCGkD2tGHeHRqcSjHB8L1ybQ1cE=;
        b=lKLErIPxjT8Zds/mqCUdbpmIj+1JHZnHiYmn8QQm8ouVfDDAJOVFxgt8keF5GlkGSy
         PSBknjzcoKGofQVn7Yw2i/KjBrDSQfwtiHe/oxy0zks8CrOGaHWN9iRgtepL87UpT7fj
         0KQNdV4R+BYVVja/CNo4d5f6rCYXlwfyOcnjzXUnN7I/Ibk44942sQu4TS5Kbul0wAsV
         bl7bX6aNboApzCmmj6M3GJ8KyLq0a1k7fSr9dTszR7+H1OR8wPuaUurwWM4W8h4YbQz1
         FZN6aPkh1wcX2z5F5I6NFCzXPoO/aOmvuJraaW+OJg/0thHc0ZqmZ187P+WPxuAzkb/p
         0QWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXElXwTAGJTiEkdtOvnT/Ug3LMFeeDNil3ET5gLFxZxkGKnR/c1
	WsTdvwrLpzAGWHapQWFNLS6YExmfSjMjO1jFpERzsfegm0WdUFm2L3nr1S5d41L5PhFIHMSuF8Q
	5v9XW7W0dWopDAQYVtLYbbfZMNzvk6Q8pNSXgc60+IRcJ1K3Ap3eFrxBZkJ/MsXqo1A==
X-Received: by 2002:a17:906:2d42:: with SMTP id e2mr15557185eji.153.1554703422400;
        Sun, 07 Apr 2019 23:03:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyS6nEBWNUD24b1Gqs4izuJbXl3/lLKlw48KNV4snTJTpJ76sMKFwTKImSkKn/s//r5Au2j
X-Received: by 2002:a17:906:2d42:: with SMTP id e2mr15557128eji.153.1554703421233;
        Sun, 07 Apr 2019 23:03:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554703421; cv=none;
        d=google.com; s=arc-20160816;
        b=Roz1ZihAyVS3Wbq3o/+Iq8jypl2Ay23GNa70HpWnkbay11h97D53UXjTrYBBWMl5+x
         u2BtjSt5i2tOnnMp9RlBk9Hccs2aXBj4hGnLpNBiVuwaSEqPmXdvSTru9J9AeArFCHI6
         SALG3JjI3Z8j5ttYvnmjLqkuIRw+kt52ip7SbyEVNyBtibSoB088bXyCYhXFOw6IrX4N
         hfndNWpiptp4idglqXgLEPuDHc6BYdsfpn1gNcM3MrdoJgKlAIFnx0EqQrkfJKwg395p
         v/QkTuwcPGl40DhbGRPo+swYVkDj7NOt6yAb/FtuoH4AhnAMpS2C2m+6wrixLnGvmZQU
         YEPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=duMszPrz3cQunSb4kCGkD2tGHeHRqcSjHB8L1ybQ1cE=;
        b=VVjayeXHIUbsG8bvwgeoaJ4esGPauDaRBaFqJcaH+ZMKz0ZWnntsg6lzKPfhj9P6U4
         6HX8zxJmrvXp8vxj/wLfN7D8zU3kVljCnQfISNaTn4OkBU5yn8qJaFRljiLYB91zgtUL
         ZpK5NxW7SDc23Iwpk4N7+II5izcegEOLnC0P4r7ch63R4lYJBz8F4Y056kCuFqPo0XIV
         K7+TCjKjke8tmY8MSn7JcMXa2gp97W33tx7Ue8cRHI9qjJInDQGA+xBTCuE634qC5siV
         mOpJA0RivqSoSjXYneh6puzZJ6muNLo7TE58exzV1BU9liNYlj3lgHIM0YDGFqK+2iNf
         qqRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h5si718478edf.424.2019.04.07.23.03.40
        for <linux-mm@kvack.org>;
        Sun, 07 Apr 2019 23:03:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9885115BF;
	Sun,  7 Apr 2019 23:03:39 -0700 (PDT)
Received: from [10.162.42.195] (p8cg001049571a15.blr.arm.com [10.162.42.195])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 30A803F59C;
	Sun,  7 Apr 2019 23:03:31 -0700 (PDT)
Subject: Re: [PATCH 6/6] arm64/mm: Enable ZONE_DEVICE
To: Ira Weiny <ira.weiny@intel.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Robin Murphy <robin.murphy@arm.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-arm-kernel@lists.infradead.org, Linux MM <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>, Will Deacon
 <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>,
 james.morse@arm.com, Mark Rutland <mark.rutland@arm.com>,
 cpandya@codeaurora.org, arunks@codeaurora.org, osalvador@suse.de,
 Logan Gunthorpe <logang@deltatee.com>, David Hildenbrand <david@redhat.com>,
 cai@lca.pw, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-7-git-send-email-anshuman.khandual@arm.com>
 <ea5567c7-caad-8a4e-7c6f-cec4b772a526@arm.com>
 <0d72db39-e20d-1cbd-368e-74dda9b6c936@arm.com>
 <CAPcyv4h5YskvjR306FsHnVHpPjnT4s2JPJXgk6CxiMz8bjhqkg@mail.gmail.com>
 <a16a9867-7019-10ab-1901-c114bcd8712b@arm.com>
 <CAPcyv4j0Z2ASeJGgS18Bpgr_2F8XdZdCq4T9W5fgkG1oWKtNHg@mail.gmail.com>
 <20190408040346.GA26243@iweiny-DESK2.sc.intel.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <946f090f-e048-cb9e-053e-371029fd7ba8@arm.com>
Date: Mon, 8 Apr 2019 11:33:35 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190408040346.GA26243@iweiny-DESK2.sc.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/08/2019 09:33 AM, Ira Weiny wrote:
> On Sun, Apr 07, 2019 at 03:11:00PM -0700, Dan Williams wrote:
>> On Thu, Apr 4, 2019 at 2:47 AM Robin Murphy <robin.murphy@arm.com> wrote:
>>>
>>> On 04/04/2019 06:04, Dan Williams wrote:
>>>> On Wed, Apr 3, 2019 at 9:42 PM Anshuman Khandual
>>>> <anshuman.khandual@arm.com> wrote:
>>>>>
>>>>>
>>>>>
>>>>> On 04/03/2019 07:28 PM, Robin Murphy wrote:
>>>>>> [ +Dan, Jerome ]
>>>>>>
>>>>>> On 03/04/2019 05:30, Anshuman Khandual wrote:
>>>>>>> Arch implementation for functions which create or destroy vmemmap mapping
>>>>>>> (vmemmap_populate, vmemmap_free) can comprehend and allocate from inside
>>>>>>> device memory range through driver provided vmem_altmap structure which
>>>>>>> fulfils all requirements to enable ZONE_DEVICE on the platform. Hence just
>>>>>>
>>>>>> ZONE_DEVICE is about more than just altmap support, no?
>>>>>
>>>>> Hot plugging the memory into a dev->numa_node's ZONE_DEVICE and initializing the
>>>>> struct pages for it has stand alone and self contained use case. The driver could
>>>>> just want to manage the memory itself but with struct pages either in the RAM or
>>>>> in the device memory range through struct vmem_altmap. The driver may not choose
>>>>> to opt for HMM, FS DAX, P2PDMA (use cases of ZONE_DEVICE) where it may have to
>>>>> map these pages into any user pagetable which would necessitate support for
>>>>> pte|pmd|pud_devmap.
>>>>
>>>> What's left for ZONE_DEVICE if none of the above cases are used?
>>>>
>>>>> Though I am still working towards getting HMM, FS DAX, P2PDMA enabled on arm64,
>>>>> IMHO ZONE_DEVICE is self contained and can be evaluated in itself.
>>>>
>>>> I'm not convinced. What's the specific use case.
>>>
>>> The fundamental "roadmap" reason we've been doing this is to enable
>>> further NVDIMM/pmem development (libpmem/Qemu/etc.) on arm64. The fact
>>> that ZONE_DEVICE immediately opens the door to the various other stuff
>>> that the CCIX folks have interest in is a definite bonus, so it would
>>> certainly be preferable to get arm64 on par with the current state of
>>> things rather than try to subdivide the scope further.
>>>
>>> I started working on this from the ZONE_DEVICE end, but got bogged down
>>> in trying to replace my copied-from-s390 dummy hot-remove implementation
>>> with something proper. Anshuman has stepped in to help with hot-remove
>>> (since we also have cloud folks wanting that for its own sake), so is
>>> effectively coming at the problem from the opposite direction, and I'll
>>> be the first to admit that we've not managed the greatest job of meeting
>>> in the middle and coordinating our upstream story; sorry about that :)
>>>
>>> Let me freshen up my devmap patches and post them properly, since that
>>> discussion doesn't have to happen in the context of hot-remove; they're
>>> effectively just parallel dependencies for ZONE_DEVICE.
>>
>> Sounds good. It's also worth noting that Ira's recent patches for
>> supporting get_user_pages_fast() for "longterm" pins relies on
>> PTE_DEVMAP to determine when fast-GUP is safe to proceed, or whether
>> it needs to fall back to slow-GUP. So it really is the case that
>> "devmap" support is an assumption for ZONE_DEVICE.
> 
> Could you cc me on the patches when you post?

Sure will do.

