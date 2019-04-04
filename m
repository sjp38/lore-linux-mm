Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87F0AC10F05
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:25:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E492206DF
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:25:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E492206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFFEE6B000D; Thu,  4 Apr 2019 01:25:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAEFB6B000E; Thu,  4 Apr 2019 01:25:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC53C6B0266; Thu,  4 Apr 2019 01:25:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1B56B000D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 01:25:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c41so748019edb.7
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 22:25:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2n1pA2mwlwQsKIZqSTOKYQ2FK0GwFRWvbXpAPOwlfxQ=;
        b=g2PHZoa5engFofBEP19oaHfwRJBzi3rKLq4e0GAUMnNcprqMWuogKIsXgU71NXpy5p
         NJTudgSMeA0o/xXBDSznHZFbFHQJq77pTbrGkWpFo5UWVjl/EStTkIE4IJqdofr0mXr3
         qEK0dR9ez5bEHkmXRNV0GafZtwWPHIyDlcBdN5KLH+hgWX4ehqKSBXMogToji1l0U3XT
         8J5VRiUBY5WfBz5L2LT+dicedKCb4zfK7lowtNwI0u+/JRaY57koD9ilxLstaZgsIvqH
         1+MZIvzkM1bo4hXYLWtFMBZJH27dEtxpqp8xpdroDnjKv0yYblhNCK9olza2ZgCp4yqz
         V51g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUIk+VPv2yc6FbXTgBFFJoOldpGp6TWNZk+HFanrg9haMcmVI7R
	GbcawSuXlbHQK95erAXWbYNQVtVInzCKlfOJ8NLCXkBfX3Atcnw3wHwS/dNAL2vgCd2xfk3XisP
	ocBQYbRtHtufXdi+tRddmfBgi12xXrtNDXnUGqidv+jubgd8UjYkrPo7lHOMSQ6u35A==
X-Received: by 2002:a50:878f:: with SMTP id a15mr2308147eda.196.1554355543072;
        Wed, 03 Apr 2019 22:25:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz95Ci9pdpDYe9vMP0qryn25OyQJUiWgNt0Bwjt/ZXe1RTnnI9GFXk3LIi9GH519RgOdH4t
X-Received: by 2002:a50:878f:: with SMTP id a15mr2308111eda.196.1554355542328;
        Wed, 03 Apr 2019 22:25:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554355542; cv=none;
        d=google.com; s=arc-20160816;
        b=H5bNnhmemLCkXnJD+k9ggJNpQaPdsDKCsmyhNDoLZyvzlwXLnF8f/lnkDSWctWLew5
         8haH+DO6Vs+cLhDmg6itoKpyUwOUL1iXR8FwyixbTU/8whZ3+n6KRQlI7nPv98rIwVUW
         qNSjmvGwXExMIv36iTMhdmW7aeWhFJ0Y79zVgNAd3VZO4apDtbWQe7zBb86w3pyFvdHw
         owV4x6K2VnbZEtJK29bjDNqspgopT+lSxp4IvLLYfWM77+yks6nA5p267mYgJ3O6hajB
         ZFI7DE3o/XL4vD5Z9a7gp0VhKsrVM0jzOf6w3TT4U35iY59COk3pnoZDp2eUHH3gGqWD
         zl4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=2n1pA2mwlwQsKIZqSTOKYQ2FK0GwFRWvbXpAPOwlfxQ=;
        b=T9uLL0T3tzLrAYyNLKkoXzk9KHfCttaDriz3l8uRgJYi0lAnET02705ARS/179TP1Y
         EpxAGsiyblrk+FUiIl1AiuQDNuBoxBgC4G7hBPXA9IE5kdzEq3x9AetDo9IxowrVzzTJ
         Hy/ZfMuV3q9urq8wr67fZvmvFncPr0pBEk083U+dTGyDAz3KgzXjsfTccj4+iMeq8ehV
         bXr2rfoPMrl4j/mSbjK//Ry9aSgB+YCiDQkXZV4WDLIBHajrBrUBNRzNlIag0B9EsUJ/
         vIXbW/caxvgb6M7DcxI5ljAUFrItNPzY/GsVnfmwE9RSYOr/XybIihWa/r0lb/Tv3rYM
         lkQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p23si4332199eju.122.2019.04.03.22.25.42
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 22:25:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 48BD6A78;
	Wed,  3 Apr 2019 22:25:41 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1C48C3F721;
	Wed,  3 Apr 2019 22:25:34 -0700 (PDT)
Subject: Re: [PATCH 1/6] arm64/mm: Enable sysfs based memory hot add interface
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 logang@deltatee.com, pasha.tatashin@oracle.com, cai@lca.pw
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-2-git-send-email-anshuman.khandual@arm.com>
 <4b9dd2b0-3b11-608c-1a40-9a3d203dd904@redhat.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <fc9dadfa-6557-ecef-f027-7f3af098b55b@arm.com>
Date: Thu, 4 Apr 2019 10:55:36 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <4b9dd2b0-3b11-608c-1a40-9a3d203dd904@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/03/2019 01:50 PM, David Hildenbrand wrote:
> On 03.04.19 06:30, Anshuman Khandual wrote:
>> Sysfs memory probe interface (/sys/devices/system/memory/probe) can accept
>> starting physical address of an entire memory block to be hot added into
>> the kernel. This is in addition to the existing ACPI based interface. This
>> just enables it with the required config CONFIG_ARCH_MEMORY_PROBE.
>>
> We recently discussed that the similar interface for removal should
> rather be moved to a debug/test module.

Can we maintain such a debug/test module mainline and enable it when required. Or
can have both add and remove interface at /sys/kernel/debug/ just for testing
purpose.

> 
> I wonder if we should try to do the same for the sysfs probing
> interface. Rather try to get rid of it than open the doors for more users.
> 

I understand your concern. Will drop this patch.

