Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70DC0C41517
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:18:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2591222ADC
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:18:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2591222ADC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAC598E0009; Wed, 24 Jul 2019 10:18:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5D8B8E0002; Wed, 24 Jul 2019 10:18:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B25428E0009; Wed, 24 Jul 2019 10:18:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6183D8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:18:51 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so30255196ede.23
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:18:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=11CMu/7BmDoCfty8+gzoMF1Pyyqj3Q052uQSz3v70rI=;
        b=lEnQYsQ6KpnS5JIRL0rfcFoQzvCg0rKyQek/aooByxoK2dedUX9+mByI6ChbDpgLSw
         l0A+bJXV6s0p618CT+5PPIF0oNKhkkNzJjRmeG327GunqS8DPCu0XXiMPNAQP/B9zdzz
         go3bxE8Piu2JcbTGMiMuhmcRelguxsQ4o+JPv5U3yi/S1O5WBDUnYSPN9Q4jVCBFz0Qq
         fFpS+5/GWt6LqPz8imz/ibY+NGbPgZG3vLzwpkW5PPTdnmd8jqfna6kVrvUvgjMFtLP/
         JjpmSOF7LZyie2e16Qxx6dv1qUI3GJCVB+Ot4UD4wXoDyx8/aBaY/KkAzGz1AiZ69gwI
         K2Qw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWhIWeiyxGULL2Bi7EFQzgL7ohnukNGXQ4GuCQivw2Woa67z1Qu
	24A5boeKKlK7bXQQLrglmYaNCwZMzYa4s++cc4mk7LkLte5/rGdt0M26DkYaS8LdsfmIXf39lvf
	u6lReLjQpMvol5lcaxigGWU0pxVUmJzdolZ8irfhX9B+qMcNLsMt3dTr9bc1l9c1+sg==
X-Received: by 2002:a17:906:3098:: with SMTP id 24mr64182210ejv.106.1563977930928;
        Wed, 24 Jul 2019 07:18:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxR36ev/vBttgwwCpt8CQLford9Iy6+Saq4hw5Gr31l9iYRG72UizETnN3fg4q16OTbGvQT
X-Received: by 2002:a17:906:3098:: with SMTP id 24mr64182142ejv.106.1563977930003;
        Wed, 24 Jul 2019 07:18:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563977930; cv=none;
        d=google.com; s=arc-20160816;
        b=R8f4oJHXYcC4G/aIPvTJACQ4myBAUAWENr/v3tyKWCh4pmKCxT6t0SMStfY2AT33H2
         XPJjL/WBlbkOWhppU/ytiTQo29k9NXLjyPsaEWRKzJMECrmWKlh4IwlgPHRGJ3W+4kIN
         NEc51Kkhf94Ai1Md6jEz1m0TiPOnSqHfugGqT2Jwg93C5/+dMd+rXpx2awYdBC5Tp1Xd
         IvEJ5AJzCxA8KHSug0GeZfl6ED5surPNW/u+Vu1EUnbHPHx+teQ4k7PZGh/5ui2uyw6o
         Cr2YhXXm1qH/dOvomQtTgW6R4b2x+goWCUamkGs9BToYEfozPk9Lf9cxzMKfK4EeZShJ
         ggew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=11CMu/7BmDoCfty8+gzoMF1Pyyqj3Q052uQSz3v70rI=;
        b=xcFvgsIrcRhSzgJ24eHBii1U7qyi4gC7hrNMEMmBbC1h36k9jf56fuP4SSUj0mIilt
         Kr/iRExd6AkLASYr1bvqIHx3NqfHpEY7xO5hkYDWlJuA32jVDAV9aE6KqqkyyGOoH6NP
         QmLtgPQzswspscKTHjFH1dYHOox8wQqxV1PGb3NqMysLj5KUUWZfHyg7eVRl8e+8WQfR
         ZKnnrv6FO/D3wuBkjx8NjZ6fUH8Bh6R4L8zW1MANV2wxsNIJe9X/u/xeMcAhG8RygoJg
         byzDUNc017quOI/hueKx15+L4ago1Ip8cDLpqfwhEYrkboP0nmcwcLCI1LwC6Zo2Utfb
         tB1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id s14si7971733ejq.332.2019.07.24.07.18.48
        for <linux-mm@kvack.org>;
        Wed, 24 Jul 2019 07:18:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0319428;
	Wed, 24 Jul 2019 07:18:48 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 55C7A3F71A;
	Wed, 24 Jul 2019 07:18:45 -0700 (PDT)
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Mark Rutland <mark.rutland@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Andrew Morton
 <akpm@linux-foundation.org>, Will Deacon <will@kernel.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190723101639.GD8085@lakrids.cambridge.arm.com>
 <e108b8a6-deca-e69c-b338-52a98b14be86@arm.com>
 <alpine.DEB.2.21.1907241541570.1791@nanos.tec.linutronix.de>
From: Steven Price <steven.price@arm.com>
Message-ID: <fd898367-b44e-9328-bdab-7a3de0db6bda@arm.com>
Date: Wed, 24 Jul 2019 15:18:43 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1907241541570.1791@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 24/07/2019 14:57, Thomas Gleixner wrote:
> On Wed, 24 Jul 2019, Steven Price wrote:
>> On 23/07/2019 11:16, Mark Rutland wrote:
>>> Are there any visible changes to the arm64 output?
>>
>> arm64 output shouldn't change. I've confirmed that "efi_page_tables" is
>> identical on a Juno before/after the change. "kernel_page_tables"
>> obviously will vary depending on the exact layout of memory, but the
>> format isn't changed.
>>
>> x86 output does change due to patch 14. In this case the change is
>> removing the lines from the output of the form...
>>
>>> 0xffffffff84800000-0xffffffffa0000000         440M                               pmd
>>
>> ...which are unpopulated areas of the memory map. Populated lines which
>> have attributes are unchanged.
> 
> Having the hole size and the level in the dump is a very conveniant thing.
> 
> Right now we have:
> 
> 0xffffffffc0427000-0xffffffffc042b000          16K     ro                     NX pte
> 0xffffffffc042b000-0xffffffffc042e000          12K     RW                     NX pte
> 0xffffffffc042e000-0xffffffffc042f000           4K                               pte
> 0xffffffffc042f000-0xffffffffc0430000           4K     ro                     x  pte
> 0xffffffffc0430000-0xffffffffc0431000           4K     ro                     NX pte
> 0xffffffffc0431000-0xffffffffc0433000           8K     RW                     NX pte
> 0xffffffffc0433000-0xffffffffc0434000           4K                               pte
> 0xffffffffc0434000-0xffffffffc0436000           8K     ro                     x  pte
> 0xffffffffc0436000-0xffffffffc0438000           8K     ro                     NX pte
> 0xffffffffc0438000-0xffffffffc043a000           8K     RW                     NX pte
> 0xffffffffc043a000-0xffffffffc043f000          20K                               pte
> 0xffffffffc043f000-0xffffffffc0444000          20K     ro                     x  pte
> 0xffffffffc0444000-0xffffffffc0447000          12K     ro                     NX pte
> 0xffffffffc0447000-0xffffffffc0449000           8K     RW                     NX pte
> 0xffffffffc0449000-0xffffffffc044f000          24K                               pte
> 0xffffffffc044f000-0xffffffffc0450000           4K     ro                     x  pte
> 0xffffffffc0450000-0xffffffffc0451000           4K     ro                     NX pte
> 0xffffffffc0451000-0xffffffffc0453000           8K     RW                     NX pte
> 0xffffffffc0453000-0xffffffffc0458000          20K                               pte
> 0xffffffffc0458000-0xffffffffc0459000           4K     ro                     x  pte
> 0xffffffffc0459000-0xffffffffc045b000           8K     ro                     NX pte
> 
> with your change this becomes:
> 
> 0xffffffffc0427000-0xffffffffc042b000          16K     ro                     NX pte
> 0xffffffffc042b000-0xffffffffc042e000          12K     RW                     NX pte
> 0xffffffffc042f000-0xffffffffc0430000           4K     ro                     x  pte
> 0xffffffffc0430000-0xffffffffc0431000           4K     ro                     NX pte
> 0xffffffffc0431000-0xffffffffc0433000           8K     RW                     NX pte
> 0xffffffffc0434000-0xffffffffc0436000           8K     ro                     x  pte
> 0xffffffffc0436000-0xffffffffc0438000           8K     ro                     NX pte
> 0xffffffffc0438000-0xffffffffc043a000           8K     RW                     NX pte
> 0xffffffffc043f000-0xffffffffc0444000          20K     ro                     x  pte
> 0xffffffffc0444000-0xffffffffc0447000          12K     ro                     NX pte
> 0xffffffffc0447000-0xffffffffc0449000           8K     RW                     NX pte
> 0xffffffffc044f000-0xffffffffc0450000           4K     ro                     x  pte
> 0xffffffffc0450000-0xffffffffc0451000           4K     ro                     NX pte
> 0xffffffffc0451000-0xffffffffc0453000           8K     RW                     NX pte
> 0xffffffffc0458000-0xffffffffc0459000           4K     ro                     x  pte
> 0xffffffffc0459000-0xffffffffc045b000           8K     ro                     NX pte
> 
> which is 5 lines less, but a pain to figure out the size of the holes. And
> it becomes even more painful when the holes go across different mapping
> levels.
> 
> From your 14/N changelog:
> 
>> This keeps the output shorter and will help with a future change
> 
> I don't care about shorter at all. It's debug information.

Sorry, the "shorter" part was because Dave Hansen originally said[1]:
> I think I'd actually be OK with the holes just not showing up.  I
> actually find it kinda hard to read sometimes with the holes in there.
> I'd be curious what others think though.

[1]
https://lore.kernel.org/lkml/5f354bf5-4ac8-d0e2-048c-0857c91a21e6@intel.com/

And I'd abbreviated "holes not showing up" as "shorter" in the commit
message - not the best wording I agree.

>> switching to using the generic page walk code as we no longer care about
>> the 'level' that the page table holes are at.
> 
> I really do not understand why you think that WE no longer care about the
> level (and the size) of the holes. I assume that WE is pluralis majestatis
> and not meant to reflect the opinion of you and everyone else.

Again, I apologise - that was sloppy wording in the commit message. By
"we" I meant the code not any particular person. In my original patch[2]
the only use of the 'depth' argument to pte_hole was to report the level
for these debug lines. Removing those lines simplified the code and at
the time nobody raised any objections.

[2]
https://lore.kernel.org/lkml/20190227170608.27963-28-steven.price@arm.com/

> I have no idea whether you ever had to do serious work with PT dump, but I
> surely have at various occasions including the PTI mess and I definitely
> found the size and the level information from holes very useful.

On arm64 we don't have those lines, but equally it's possible they might
be useful in the future. So this might be something to add.

As I said in a previous email[3] I was dropping the lines from the
output assuming nobody had any objections. Since you find these lines
useful, I'll see about reworking the change to retain the lines.

Steve

[3]
https://lore.kernel.org/lkml/26df02dd-c54e-ea91-bdd1-0a4aad3a30ac@arm.com/

