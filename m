Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEB6DC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 18:11:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E3312064A
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 18:11:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E3312064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 208166B0304; Thu, 15 Aug 2019 14:11:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BB1F6B0306; Thu, 15 Aug 2019 14:11:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CEFF6B0307; Thu, 15 Aug 2019 14:11:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0104.hostedemail.com [216.40.44.104])
	by kanga.kvack.org (Postfix) with ESMTP id DF7D46B0304
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:11:17 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8874F6111
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 18:11:17 +0000 (UTC)
X-FDA: 75825454194.08.roll51_623f477e68d52
X-HE-Tag: roll51_623f477e68d52
X-Filterd-Recvd-Size: 4848
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 18:11:14 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D3CB928;
	Thu, 15 Aug 2019 11:11:13 -0700 (PDT)
Received: from [10.1.196.105] (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1058F3F694;
	Thu, 15 Aug 2019 11:11:11 -0700 (PDT)
Subject: Re: [PATCH v1 0/8] arm64: MMU enabled kexec relocation
To: Pavel Tatashin <pasha.tatashin@soleen.com>
References: <20190801152439.11363-1-pasha.tatashin@soleen.com>
 <CA+CK2bADiBMEx9cJuXT5fQkBYFZAtxUtc7ZzjrNfEjijPZkPtw@mail.gmail.com>
From: James Morse <james.morse@arm.com>
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
Message-ID: <ba8a2519-ed95-2518-d0e8-66e8e0c14ff5@arm.com>
Date: Thu, 15 Aug 2019 19:11:10 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <CA+CK2bADiBMEx9cJuXT5fQkBYFZAtxUtc7ZzjrNfEjijPZkPtw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Pavel,

On 08/08/2019 19:44, Pavel Tatashin wrote:
> Just a friendly reminder, please send your comments on this series.

(Please don't top-post)


> It's been a week since I sent out these patches, and no feedback yet.

A week is not a lot of time, people are busy, go to conferences, some even dare to take
holiday!


> Also, I'd appreciate if anyone could test this series on vhe hardware
> with vhe kernel, it does not look like QEMU can emulate it yet

This locks up during resume from hibernate on my AMD Seattle, a regular v8.0 machine.


Please try and build the series to reduce review time. What you have here is an all-new
page-table generation API, which you switch hibernate and kexec too. This is effectively a
new implementation of hibernate and kexec. There are three things here that need review.

You have a regression in your all-new implementation of hibernate. It took six months (and
lots of review) to get the existing code right, please don't rip it out if there is
nothing wrong with it.


Instead, please just move the hibernate copy_page_tables() code, and then wire kexec up.
You shouldn't need to change anything in the copy_page_tables() code as the linear map is
the same in both cases.


It looks like you are creating the page tables just after the kexec:segments have been
loaded. This will go horribly wrong if anything changes between then and kexec time. (e.g.
memory you've got mapped gets hot-removed).
This needs to be done as late as possible, so we don't waste memory, and the world can't
change around us. Reboot notifiers run before kexec, can't we do the memory-allocation there?


> On Thu, Aug 1, 2019 at 11:24 AM Pavel Tatashin
> <pasha.tatashin@soleen.com> wrote:
>>
>> Enable MMU during kexec relocation in order to improve reboot performance.
>>
>> If kexec functionality is used for a fast system update, with a minimal
>> downtime, the relocation of kernel + initramfs takes a significant portion
>> of reboot.
>>
>> The reason for slow relocation is because it is done without MMU, and thus
>> not benefiting from D-Cache.
>>
>> Performance data
>> ----------------
>> For this experiment, the size of kernel plus initramfs is small, only 25M.
>> If initramfs was larger, than the improvements would be greater, as time
>> spent in relocation is proportional to the size of relocation.
>>
>> Previously:
>> kernel shutdown 0.022131328s
>> relocation      0.440510736s
>> kernel startup  0.294706768s
>>
>> Relocation was taking: 58.2% of reboot time
>>
>> Now:
>> kernel shutdown 0.032066576s
>> relocation      0.022158152s
>> kernel startup  0.296055880s
>>
>> Now: Relocation takes 6.3% of reboot time
>>
>> Total reboot is x2.16 times faster.

When I first saw these numbers they were ~'0.29s', which I wrongly assumed was 29 seconds.
Savings in milliseconds, for _reboot_ is a hard sell. I'm hoping that on the machines that
take minutes to kexec we'll get numbers that make this change more convincing.


Thanks,

James

