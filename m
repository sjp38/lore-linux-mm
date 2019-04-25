Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4631CC282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 03:06:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9407217FA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 03:06:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9407217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A00C6B0005; Wed, 24 Apr 2019 23:06:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44F566B0006; Wed, 24 Apr 2019 23:06:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F2EA6B0007; Wed, 24 Apr 2019 23:06:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DFA046B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 23:06:48 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n25so10973704edd.5
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 20:06:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=PpsY77+PwTM97YJsZG/lPosqTRF7hn7RCLm/WNSeCZE=;
        b=InBLZYIB1L3KoU26h+0BW0l7xhTfqr7LnDN4gi0XlNdqEv34PI2kjSsznYe2Z7jbr2
         8DNHhjT/mM8p50Rz6fOXwyTLqugf53GG8aCCq48jeV2sSv8kNabnLXnDVZL1NyXoDwgP
         6Hd8+f5I0Gb++kvI76/yr+ZvBo5Q1T96OQColiAhz1IpERWwHMlJ75BKLwLFgca3kxc9
         LxT1svPF0CzDCNlyJ33uyD8PLG5QMZ2NfoYDoUlmvXNT78xQEbgTye2CHx1cqVI48cg4
         2fJ2DJi5zfSenOKX2avjnwGTZL6lbGzl6NmxhxZqvYjfbqt0/+p08y72JJ8KBHPoUWj4
         aw1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVp7TXeR7ko4SRyqH9MEN4tBJdZ3wXSflg0BvtVcFW0skp4EXFq
	TGehfzweFrjOxwYa5VbyDLiBXm++BXzIBJG+Z+VsJYYeEnuK6Bysbgn8t5Op8B4UtMeXTPSm6EL
	On3POyCswi+CxUcBfP6kjTg5lyrB8a6G7RbVYSfuCYXfKIWNQnMPuu272Mozxw89v2g==
X-Received: by 2002:a50:b884:: with SMTP id l4mr22800634ede.10.1556161608335;
        Wed, 24 Apr 2019 20:06:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjgQ9xyyyfT5u1NVLMTkzzfWV6wW4VGj+80E01q0PBUfRas3dIrjkugcGVvfGQC8YFt8Vn
X-Received: by 2002:a50:b884:: with SMTP id l4mr22800582ede.10.1556161607200;
        Wed, 24 Apr 2019 20:06:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556161607; cv=none;
        d=google.com; s=arc-20160816;
        b=aa35ysqe+CzQXFMZhxW/wWP8jFzVhMaDbtgq60as93+fHkKyUv69gFppIV30sPTr9x
         g7jNTyR45NT41DETTFhxRA+DIcjQAAZm2FTTI5cIIgt3OUwwVUUjSOHVjRscKQCD4Toc
         VMZY8a+a2p45X4VvHKugqpWArmYEtIo9fNOsRtBalaTPnQVkWuPq2W0zFVjU+67pVWhS
         BwXluhzdqIeC7kcexdq4xFx20sJD7QoWMIuw2T/YO34C1mJRhYTqSi7DWbRrhfrke2Gm
         mcKEFzmXpMnpB5Swgfqke3eJWCvSjTlALCAjIZtV5D6AsyhlMyLoKiM3xRA0HWcKTujr
         rezA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=PpsY77+PwTM97YJsZG/lPosqTRF7hn7RCLm/WNSeCZE=;
        b=WPbXgovJOlfaxkcCXDSzwdWOgCDv8Hp+wRHQASaGldYxI85qjeyZ3LwKR+rxJwtcj9
         7xCc1QwmWtTSTWwqnhy/Zxkf5/Wvg4Q4DdHsU1yQqmAJ58o8f9+Iq2rqqVaUuzha6kdn
         7/Vlpu1XGYahxcTEfGOQtHhdWsvp66I9UGJMbpKnTW+OF/gkLKpPzxxPyWjOng1j0bGi
         jBX2jPTDIHpj1+jrAum/PG3/R0i4pr1VFknwRkTCp9RFgh0qmvAwaJxyvbvRolCMXUz4
         MgRZkH3I/iGKnHa0Q5/7riHM52yYr6iUZIzlSVN3yzGhbtGQd9QhxthYKmVU/PZmDmUY
         Wm+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x43si10033429edm.115.2019.04.24.20.06.46
        for <linux-mm@kvack.org>;
        Wed, 24 Apr 2019 20:06:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9920E374;
	Wed, 24 Apr 2019 20:06:45 -0700 (PDT)
Received: from [10.163.1.68] (unknown [10.163.1.68])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CC24F3F5AF;
	Wed, 24 Apr 2019 20:06:35 -0700 (PDT)
Subject: Re: [PATCH] arm64: configurable sparsemem section size
To: Pavel Tatashin <patatash@linux.microsoft.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 linux-nvdimm <linux-nvdimm@lists.01.org>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Dan Williams <dan.j.williams@intel.com>, Keith Busch
 <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>,
 Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>,
 Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying"
 <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>,
 Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>,
 Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 catalin.marinas@arm.com, Will Deacon <will.deacon@arm.com>,
 rppt@linux.vnet.ibm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 andrew.murray@arm.com, james.morse@arm.com,
 Marc Zyngier <marc.zyngier@arm.com>, sboyd@kernel.org,
 linux-arm-kernel@lists.infradead.org
References: <20190423203843.2898-1-pasha.tatashin@soleen.com>
 <7f7499bd-8d48-945b-6d69-60685a02c8da@arm.com>
 <CA+CK2bCD11x64pJj5gSnsu5jsUqJyU6o+=J4K8oYAsHqz9ULqQ@mail.gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <cc2f6523-9ebc-54aa-34a1-32a661317342@arm.com>
Date: Thu, 25 Apr 2019 08:36:38 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <CA+CK2bCD11x64pJj5gSnsu5jsUqJyU6o+=J4K8oYAsHqz9ULqQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/25/2019 01:18 AM, Pavel Tatashin wrote:
> On Wed, Apr 24, 2019 at 5:07 AM Anshuman Khandual
> <anshuman.khandual@arm.com> wrote:
>>
>> On 04/24/2019 02:08 AM, Pavel Tatashin wrote:
>>> sparsemem section size determines the maximum size and alignment that
>>> is allowed to offline/online memory block. The bigger the size the less
>>> the clutter in /sys/devices/system/memory/*. On the other hand, however,
>>> there is less flexability in what granules of memory can be added and
>>> removed.
>>
>> Is there any scenario where less than a 1GB needs to be added on arm64 ?
> 
> Yes, DAX hotplug loses 1G of memory without allowing smaller sections.
> Machines on which we are going to be using this functionality have 8G
> of System RAM, therefore losing 1G is a big problem.
> 
> For details about using scenario see this cover letter:
> https://lore.kernel.org/lkml/20190421014429.31206-1-pasha.tatashin@soleen.com/

Its loosing 1GB because devdax has 2M alignment ? IIRC from Dan's subsection memory
hot add series 2M comes from persistent memory HW controller's limitations. Does that
limitation applicable across all platforms including arm64 for all possible persistent
memory vendors. I mean is it universal ? IIUC subsection memory hot plug series is
still getting reviewed. Hence should not we wait for it to get merged before enabling
applicable platforms to accommodate these 2M limitations.

> 
>>
>>>
>>> Recently, it was enabled in Linux to hotadd persistent memory that
>>> can be either real NV device, or reserved from regular System RAM
>>> and has identity of devdax.
>>
>> devdax (even ZONE_DEVICE) support has not been enabled on arm64 yet.
> 
> Correct, I use your patches to enable ZONE_DEVICE, and  thus devdax on ARM64:
> https://lore.kernel.org/lkml/1554265806-11501-1-git-send-email-anshuman.khandual@arm.com/
> 
>>
>>>
>>> The problem is that because ARM64's section size is 1G, and devdax must
>>> have 2M label section, the first 1G is always missed when device is
>>> attached, because it is not 1G aligned.
>>
>> devdax has to be 2M aligned ? Does Linux enforce that right now ?
> 
> Unfortunately, there is no way around this. Part of the memory can be
> reserved as persistent memory via device tree.
>         memory@40000000 {
>                 device_type = "memory";
>                 reg = < 0x00000000 0x40000000
>                         0x00000002 0x00000000 >;
>         };
> 
>         pmem@1c0000000 {
>                 compatible = "pmem-region";
>                 reg = <0x00000001 0xc0000000
>                        0x00000000 0x80000000>;
>                 volatile;
>                 numa-node-id = <0>;
>         };
> 
> So, while pmem is section aligned, as it should be, the dax device is
> going to be pmem start address + label size, which is 2M. The actual

Forgive my ignorance here but why dax device label size is 2M aligned. Again is that
because of some persistent memory HW controller limitations ?

> DAX device starts at:
> 0x1c0000000 + 2M.
> 
> Because section size is 1G, the hotplug will able to add only memory
> starting from
> 0x1c0000000 + 1G

Got it but as mentioned before we will have to make sure that 2M alignment requirement
is universal else we will be adjusting this multiple times.

> 
>> 27 and 28 do not even compile for ARM64_64_PAGES because of MAX_ORDER and
>> SECTION_SIZE mismatch.

Even with 27 bits its 128 MB section size. How does it solve the problem with 2M ?
The patch just wanted to reduce the memory wastage ?

> 
> Can you please elaborate what configs are you using? I have no
> problems compiling with 27 and 28 bit.

After applying your patch [1] on current mainline kernel [2].

$make defconfig

CONFIG_ARM64_64K_PAGES=y
CONFIG_ARM64_VA_BITS_48=y
CONFIG_ARM64_VA_BITS=48
CONFIG_ARM64_PA_BITS_48=y
CONFIG_ARM64_PA_BITS=48
CONFIG_ARM64_SECTION_SIZE_BITS=27

[1] https://patchwork.kernel.org/patch/10913737/
[2] git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

It fails with

  CC      arch/arm64/kernel/asm-offsets.s
In file included from ./include/linux/gfp.h:6,
                 from ./include/linux/slab.h:15,
                 from ./include/linux/resource_ext.h:19,
                 from ./include/linux/acpi.h:26,
                 from ./include/acpi/apei.h:9,
                 from ./include/acpi/ghes.h:5,
                 from ./include/linux/arm_sdei.h:14,
                 from arch/arm64/kernel/asm-offsets.c:21:
./include/linux/mmzone.h:1095:2: error: #error Allocator MAX_ORDER exceeds SECTION_SIZE
 #error Allocator MAX_ORDER exceeds SECTION_SIZE

