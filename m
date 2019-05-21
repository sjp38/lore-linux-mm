Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71AFEC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:08:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 329AA21479
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 02:08:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 329AA21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFE566B0003; Mon, 20 May 2019 22:08:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAF726B0005; Mon, 20 May 2019 22:08:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9DE26B0006; Mon, 20 May 2019 22:08:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9AA6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 22:08:46 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c26so28092096eda.15
        for <linux-mm@kvack.org>; Mon, 20 May 2019 19:08:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=zL0vNtf9QjRlLGdRhNUHBDM2wsOI0slDwuSdOXadX4Q=;
        b=e82fH53DyWwhCKj0ypWzmuqyqQwZ4CmHpw+mhSR/29xRLOrK6s2B2kRO0gNI200+o1
         D9L7XvggkYAqGDTv8rJuK6/SMEcjQ7LH9np+TFlrbNWtWlRPVOr2Jkv9nurZIrC5imjz
         UiW3ee54vG4FM01HfinyMT+6iLgzd1fWFCNx7nL/n/uvqB46PJgnmB/cRUUcOo0LA1OH
         gXc+LGhi6WVLersI2g/foCWDZYaHpwx/CJwT7sIRK+bYPNSxwjXlFTgo5J1U+SyBMuKM
         +bhvLugFA7tA8qJtwoGq4KOe/4S2XsbskeGKX1ORvvdy9DP15773izv+OmPUjIgRSwxe
         nFyA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWZDFFBrz1ecNaHDLx/liZMjunp6BTdmMxsThoI7G/FA8LGANmR
	PT3cC44j14McX+WRVE4Q23N/uEMkqbiPtgG3SHUCyciq+uTcr21zDvYGzY6LZc3BOok0p8O2PgS
	r113LT4GGj5qgGAmX9V33C7AjunoXyYNsqQfT6WUQD2qcXwZNeWwbPbf4IHteaoRn7w==
X-Received: by 2002:a17:906:e282:: with SMTP id gg2mr7120195ejb.38.1558404525916;
        Mon, 20 May 2019 19:08:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/I8Hij7OHnTwI6IU8LNGl+fzCpgx7yuMQMtiicK93BdjhJXxsaAdKW0U9/VTp0tLfJEOB
X-Received: by 2002:a17:906:e282:: with SMTP id gg2mr7120145ejb.38.1558404525058;
        Mon, 20 May 2019 19:08:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558404525; cv=none;
        d=google.com; s=arc-20160816;
        b=MR0pWZsDpg7mRfss2jGa0PiG7Ttli71BeErMsFkkRfXj9wqNVG5OunjX5eFolRC268
         mLwMV+MucT9ADYvCVyoV54PzjN0ixo/85TmHd43Op/VpV6lvzubcl88TrfyWASPZ70I0
         YjSuchAXn1YlNH88ZR/zuDx9U0Mw2MORnZLoothfjoPHC0iRBFNIhm8wc6UVqSb47GXP
         kcqCEszO00s1wWrpwZsuiyATziYXp7Csoih1XePkq1zYgg3IMTdHR2Co3QnZ7A7V67Ef
         9zp/pgUg5App4q8Y1ZA4oSDUZImQmQa6GMuEQ+N2tU3Q84jcELvaKKbUMJ7pe3+nh369
         Nu4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=zL0vNtf9QjRlLGdRhNUHBDM2wsOI0slDwuSdOXadX4Q=;
        b=uptshse5DhSNQmSsoiLFj7FQhruoV4LTYLo1tDPTZpTRrL76nmBDRQSJVgAQ4+j+cH
         zcaF9aK06SMNvMLAR9RGcuVBTgyREwV6egR2wL1puXi9zMbMrOkM9fxw2t9Z3WUOqloy
         P+vVh0/lkblSYj/PROsX3j55P1rnd5eIPvKJRvEstuPSN6nMJts4NC0mZCxac3vHCIVH
         e2pRg4w2KcgG1dEhkWuNhARhXj3ZFy8cTIo+oJnbHFbyLQZyt88yy/I06NDhJDLIYW/8
         Ut6mj8aiPU30b0N4m16qajqOldKodR76X6TUtr2GJ8boCGU78GLjgIFsb7UYbDTUEmjF
         gUBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z10si7131980edd.210.2019.05.20.19.08.44
        for <linux-mm@kvack.org>;
        Mon, 20 May 2019 19:08:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CC1BB341;
	Mon, 20 May 2019 19:08:43 -0700 (PDT)
Received: from [10.162.42.136] (p8cg001049571a15.blr.arm.com [10.162.42.136])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B102A3F718;
	Mon, 20 May 2019 19:08:41 -0700 (PDT)
Subject: Re: [PATCH] mm/dev_pfn: Exclude MEMORY_DEVICE_PRIVATE while computing
 virtual address
To: Dan Williams <dan.j.williams@intel.com>,
 Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>, Laurent Dufour <ldufour@linux.vnet.ibm.com>
References: <1558089514-25067-1-git-send-email-anshuman.khandual@arm.com>
 <20190517145050.2b6b0afdaab5c3c69a4b153e@linux-foundation.org>
 <cb8cbd57-9220-aba9-7579-dbcf35f02672@arm.com>
 <20190520192721.GA4049@redhat.com>
 <CAPcyv4gN0Pz66a_dEMxkS5xvCyPoboGEkyxZFHQU3L2DDj8fAg@mail.gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <502ec91a-4019-39c7-537d-f86a7348ca40@arm.com>
Date: Tue, 21 May 2019 07:38:53 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gN0Pz66a_dEMxkS5xvCyPoboGEkyxZFHQU3L2DDj8fAg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/21/2019 01:03 AM, Dan Williams wrote:
> On Mon, May 20, 2019 at 12:27 PM Jerome Glisse <jglisse@redhat.com> wrote:
>>
>> On Mon, May 20, 2019 at 11:07:38AM +0530, Anshuman Khandual wrote:
>>> On 05/18/2019 03:20 AM, Andrew Morton wrote:
>>>> On Fri, 17 May 2019 16:08:34 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
>>>>
>>>>> The presence of struct page does not guarantee linear mapping for the pfn
>>>>> physical range. Device private memory which is non-coherent is excluded
>>>>> from linear mapping during devm_memremap_pages() though they will still
>>>>> have struct page coverage. Just check for device private memory before
>>>>> giving out virtual address for a given pfn.
>>>>
>>>> I was going to give my standard "what are the user-visible runtime
>>>> effects of this change?", but...
>>>>
>>>>> All these helper functions are all pfn_t related but could not figure out
>>>>> another way of determining a private pfn without looking into it's struct
>>>>> page. pfn_t_to_virt() is not getting used any where in mainline kernel.Is
>>>>> it used by out of tree drivers ? Should we then drop it completely ?
>>>>
>>>> Yeah, let's kill it.
>>>>
>>>> But first, let's fix it so that if someone brings it back, they bring
>>>> back a non-buggy version.
>>>
>>> Makes sense.
>>>
>>>>
>>>> So...  what (would be) the user-visible runtime effects of this change?
>>>
>>> I am not very well aware about the user interaction with the drivers which
>>> hotplug and manage ZONE_DEVICE memory in general. Hence will not be able to
>>> comment on it's user visible runtime impact. I just figured this out from
>>> code audit while testing ZONE_DEVICE on arm64 platform. But the fix makes
>>> the function bit more expensive as it now involve some additional memory
>>> references.
>>
>> A device private pfn can never leak outside code that does not understand it
>> So this change is useless for any existing users and i would like to keep the
>> existing behavior ie never leak device private pfn.
> 
> The issue is that only an HMM expert might know that such a pfn can
> never leak, in other words the pfn concept from a code perspective is
> already leaked / widespread. Ideally any developer familiar with a pfn
> and the core-mm pfn helpers need only worry about pfn semantics
> without being required to go audit HMM users.

Agreed.

