Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4200FC3A59F
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 18:17:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EDB42173B
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 18:17:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EDB42173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B1FF6B0003; Fri, 16 Aug 2019 14:17:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 962416B0005; Fri, 16 Aug 2019 14:17:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84F116B0007; Fri, 16 Aug 2019 14:17:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0179.hostedemail.com [216.40.44.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2056B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 14:17:26 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id EB5CD181AC9C9
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 18:17:25 +0000 (UTC)
X-FDA: 75829098450.15.plant66_40bdbbd2aa462
X-HE-Tag: plant66_40bdbbd2aa462
X-Filterd-Recvd-Size: 7018
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 18:17:24 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D6F5B28;
	Fri, 16 Aug 2019 11:17:23 -0700 (PDT)
Received: from [10.1.196.105] (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0F0C23F706;
	Fri, 16 Aug 2019 11:17:21 -0700 (PDT)
Subject: Re: [PATCH v1 0/8] arm64: MMU enabled kexec relocation
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>,
 "Eric W. Biederman" <ebiederm@xmission.com>,
 kexec mailing list <kexec@lists.infradead.org>,
 LKML <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>,
 Catalin Marinas <catalin.marinas@arm.com>, will@kernel.org,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Marc Zyngier <marc.zyngier@arm.com>,
 Vladimir Murzin <vladimir.murzin@arm.com>,
 Matthias Brugger <matthias.bgg@gmail.com>,
 Bhupesh Sharma <bhsharma@redhat.com>, linux-mm <linux-mm@kvack.org>
References: <20190801152439.11363-1-pasha.tatashin@soleen.com>
 <CA+CK2bADiBMEx9cJuXT5fQkBYFZAtxUtc7ZzjrNfEjijPZkPtw@mail.gmail.com>
 <ba8a2519-ed95-2518-d0e8-66e8e0c14ff5@arm.com>
 <CA+CK2bAqBi43Cchr=md7EPRuEWH-iuToK0PxN3ysSBQ42Hd0-g@mail.gmail.com>
From: James Morse <james.morse@arm.com>
Message-ID: <746ceee3-43a7-231d-b2f6-0991a4148a28@arm.com>
Date: Fri, 16 Aug 2019 19:17:20 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <CA+CK2bAqBi43Cchr=md7EPRuEWH-iuToK0PxN3ysSBQ42Hd0-g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Pavel,

On 15/08/2019 21:09, Pavel Tatashin wrote:
>>> Also, I'd appreciate if anyone could test this series on vhe hardware
>>> with vhe kernel, it does not look like QEMU can emulate it yet
>>
>> This locks up during resume from hibernate on my AMD Seattle, a regular v8.0 machine.
> 
> Thanks for reporting a bug I will root cause and fix it.

>> Please try and build the series to reduce review time. What you have here is an all-new
>> page-table generation API, which you switch hibernate and kexec too. This is effectively a
>> new implementation of hibernate and kexec. There are three things here that need review.
>>
>> You have a regression in your all-new implementation of hibernate. It took six months (and
>> lots of review) to get the existing code right, please don't rip it out if there is
>> nothing wrong with it.
> 
>> Instead, please just move the hibernate copy_page_tables() code, and then wire kexec up.
>> You shouldn't need to change anything in the copy_page_tables() code as the linear map is
>> the same in both cases.

> It is not really an all-new implementation of hibernate (for kexec it
> is true though). I used the current implementation of hibernate as
> bases, and simply generalized the functions by providing a flexible
> interface. So what you are asking is actually exactly what I am doing.

I disagree. The resume page-table code is the bulk of the complexity in hibernate.c. Your
first patch dumps ~200 lines of differently-complex code, and your second switches
hibernate over to it.

Instead, please move that code, keeping it as it is. git will spot the move, and the
generated diffstat should only reflect the build-system changes. You don't need to 'switch
hibernate to transitional page tables.'

Adding kexec will then show-up what needs changing, each change comes with a commit
message explaining why. Having these as 'generalisations' in the first patch is a mess.

There is existing code that we don't want to break. Any changes need to be done as a
sequence of small incremental changes. It can't be reviewed any other way.


> I realize, that I introduced a bug that I will fix.

Done as a sequence of small incremental changes, I could bisect it to the patch that
introduces the bug, and probably fix it from the description in the commit message.


>> It looks like you are creating the page tables just after the kexec:segments have been
>> loaded. This will go horribly wrong if anything changes between then and kexec time. (e.g.
>> memory you've got mapped gets hot-removed).
>> This needs to be done as late as possible, so we don't waste memory, and the world can't
>> change around us. Reboot notifiers run before kexec, can't we do the memory-allocation there?

> Kexec by design does not allow allocate during kexec time. This is
> because we cannot fail during kexec syscall.

This problem needs solving.

| Reboot notifiers run before kexec, can't we do the memory-allocation there?


> All allocations must be done during kexec load time.

This increases the memory footprint. I don't think we should waste ~2MB per GB of kernel
memory on this feature. (Assuming 4K pages and rodata_full)

Another option is to allocate this memory at load time, but then free it so it can be used
in the meantime. You can keep the list of allocated pfn, as we know they aren't in use by
the running kernel, kexec metadata, loaded images etc.

Memory hotplug would need handling carefully, as would anything that 'donates' memory to
another agent. (I suspect the TEE stuff does this, I don't know how it interacts with kexec)


> Kernel memory cannot be hot-removed, as
> it is not part of ZONE_MOVABLE, and cannot be migrated.

Today, yes. Tomorrow?, "arm64/mm: Enable memory hot remove":
https://lore.kernel.org/r/1563171470-3117-1-git-send-email-anshuman.khandual@arm.com


>>>> Previously:
>>>> kernel shutdown 0.022131328s
>>>> relocation      0.440510736s
>>>> kernel startup  0.294706768s
>>>>
>>>> Relocation was taking: 58.2% of reboot time
>>>>
>>>> Now:
>>>> kernel shutdown 0.032066576s
>>>> relocation      0.022158152s
>>>> kernel startup  0.296055880s
>>>>
>>>> Now: Relocation takes 6.3% of reboot time
>>>>
>>>> Total reboot is x2.16 times faster.
>>
>> When I first saw these numbers they were ~'0.29s', which I wrongly assumed was 29 seconds.
>> Savings in milliseconds, for _reboot_ is a hard sell. I'm hoping that on the machines that
>> take minutes to kexec we'll get numbers that make this change more convincing.

> Sure, this userland is very small kernel+userland is only 47M. Here is
> another data point: fitImage: 380M, it contains a larger userland.
> The numbers for kernel shutdown and startup are the same as this is
> the same kernel, but relocation takes: 3.58s
> shutdown: 0.02s
> relocation: 3.58s
> startup:  0.30s
> 
> Relocation take 88% of reboot time. And, we must have it under one second.

Where does this one second number come from? (was it ever a reasonable starting point?)


Thanks,

James

