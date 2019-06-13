Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFA35C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 05:37:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D93112053B
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 05:37:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D93112053B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60BE06B0003; Thu, 13 Jun 2019 01:37:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BC3A6B0005; Thu, 13 Jun 2019 01:37:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4848F6B0006; Thu, 13 Jun 2019 01:37:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F03936B0003
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 01:37:17 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a5so19943434edx.12
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:37:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=SK20g6+TBD1ycQC6ExcWYyw9IjpAQnfP5ZkXFY1WWz8=;
        b=qhuTNPZ7uGAMSY+Z9Ss2T3Td3yMP/sHevHCGdUfEoxtnRwfLeJLS6UeUmbYWIe3mdD
         L5W/w9GDqHbnjzLJGCVKcWHqda2QfatTZTKGp5TRULt3YTNrP062ZAicQiZQOamAyjbO
         kae7lpz2bBRQy3oEs8Ls9unLdg+K6EQTqCYFtlo1q798DtvVDFsgoG8danLRuElK9TqW
         B0A+CZfsACDdnOhyK8+qLLJfDsMWq8XqYEsjbcuK8+82ergg9kTOA3uw/ImpA1oYnvUu
         P2FMqvEtM0B21CnzZ5HamsZZvDUn91L3eQPjrZ76YtAVcxpnwnehaqbVVgZ1MKAY8jHe
         wJdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAU4oZttvzofpj7CM6O7jeqyv2NuF97aS9lCJx+TGz82CZl6twNx
	Ol6y7WV7Diy2V8wZi1pp0/pj4TMvsWcPxCJcRGGYRtBHxkQ3s480R8/P7tK/dG4wB8TGwRDjxYU
	35ysfgv8tstMZRi2SKJeV/GE0Jz7rCbsWTpo7CEgGwlRF5jgCmcWR6AztX+LYnGKTVw==
X-Received: by 2002:a05:6402:1710:: with SMTP id y16mr5520818edu.166.1560404237565;
        Wed, 12 Jun 2019 22:37:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpUQwQosyG4MQjDx6F0SaeT2wvuIMndSd+P8lEKuVx99V2yRieKCZ9S1yahfvoN+0OnekD
X-Received: by 2002:a05:6402:1710:: with SMTP id y16mr5520780edu.166.1560404236870;
        Wed, 12 Jun 2019 22:37:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560404236; cv=none;
        d=google.com; s=arc-20160816;
        b=ulndjpM0T5H3AkRnGEaKoNl+oKaeHjWFsqUZ6vCK68GYS2gKIdxe6XuGzbjXWbH0Sx
         bHUFhzMFGZz0MBwNZttscUC3rjV1HFqQSQ3Jt0MeTtbkmFSJodr031f7o1VgbvgE9uQp
         ZgThxlNfXgzDMLTzWY4mXJcg/+WtjGdTrLRMwYafzCA31gaaBzPNIy5uB/wPc8gYmIEc
         qQE9xWjQ1haFzncjMsmgqMxOR+ssVBKzv5pMAOs2kEGMzPMsS9hZkDHeExfyeRlpKUwF
         ynJkh0Ro5GMiD5fbAawkIeBSoPWjh5ujWq2Db58kFzQRd35+O/+rJbMdwCjSJpOz5w3O
         LYcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=SK20g6+TBD1ycQC6ExcWYyw9IjpAQnfP5ZkXFY1WWz8=;
        b=AvxKYIveS9nbkS4KUjxzH2xVxUklVeFnCeOeJA4xfn0F5EYE3EXqScQ3nJih02C06d
         eCLss11z8TeD6BkCQcyCebVeCKRYHiMw/iU2BSg1FSkrp1sUDe9K42UeUyt+s9PZo5io
         +NvCPc1d08Qe5tlGCAGw33LYIZANSycU29lqY+CCh2/HQDdUJakHVFjCqjqcymt0Gicf
         hVj2PtdTCsdBdXJujYQwsVnEkfaEMqgq3PbpdH2AISzqwwmcD6DOAmIQ0gp4rXsvcgT4
         N3fT8NlAIL7t/5lzDhzW/16PToJyyq1pJjz27hjnBs6DviHh25I0XtlNzedDbI/5odxG
         87Nw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id e26si1470736edq.401.2019.06.12.22.37.16
        for <linux-mm@kvack.org>;
        Wed, 12 Jun 2019 22:37:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3C1A428;
	Wed, 12 Jun 2019 22:37:15 -0700 (PDT)
Received: from [10.162.40.191] (p8cg001049571a15.blr.arm.com [10.162.40.191])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AB5673F73C;
	Wed, 12 Jun 2019 22:37:11 -0700 (PDT)
Subject: Re: [PATCH V5 - Rebased] mm/hotplug: Reorder memblock_[free|remove]()
 calls in try_remove_memory()
To: Andrew Morton <akpm@linux-foundation.org>,
 David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com,
 will.deacon@arm.com, ard.biesheuvel@arm.com, osalvador@suse.de,
 mhocko@suse.com, mark.rutland@arm.com
References: <36e0126f-e2d1-239c-71f3-91125a49e019@redhat.com>
 <1560252373-3230-1-git-send-email-anshuman.khandual@arm.com>
 <20190611151908.cdd6b73fd17fda09b1b3b65b@linux-foundation.org>
 <5b4f1f19-2f8d-9b8f-4240-7b728952b6fe@arm.com>
 <67f5c5ad-d753-77d8-8746-96cf4746b3e0@redhat.com>
 <20190612185450.73841b9f5af3a4189de6f910@linux-foundation.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <92ce901d-42dc-6872-1ff0-0ca13d5cefbe@arm.com>
Date: Thu, 13 Jun 2019 11:07:30 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190612185450.73841b9f5af3a4189de6f910@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/13/2019 07:24 AM, Andrew Morton wrote:
> On Wed, 12 Jun 2019 08:53:33 +0200 David Hildenbrand <david@redhat.com> wrote:
> 
>>>>> ...
>>>>>
>>>>>
>>>>> - Rebased on linux-next (next-20190611)
>>>>
>>>> Yet the patch you've prepared is designed for 5.3.  Was that
>>>> deliberate, or should we be targeting earlier kernels?
>>>
>>> It was deliberate for 5.3 as a preparation for upcoming reworked arm64 hot-remove.
>>>
>>
>> We should probably add to the patch description something like "This is
>> a preparation for arm64 memory hotremove. The described issue is not
>> relevant on other architectures."
> 
> Please.  And is there any reason to merge it separately?  Can it be
> [patch 1/3] in the "arm64/mm: Enable memory hot remove" series?

Sure it can be. I will make this [patch 1/3] in the next version for
"arm64/mm: Enable memory hot remove". Apologies for the noise here.

