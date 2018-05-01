Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2356B0005
	for <linux-mm@kvack.org>; Tue,  1 May 2018 08:53:46 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id b5-v6so4995971otf.8
        for <linux-mm@kvack.org>; Tue, 01 May 2018 05:53:46 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v26-v6si1158874oth.355.2018.05.01.05.53.45
        for <linux-mm@kvack.org>;
        Tue, 01 May 2018 05:53:45 -0700 (PDT)
Subject: Re: [PATCH v3 01/12] ACPI / APEI: Move the estatus queue code up, and
 under its own ifdef
References: <20180427153510.5799-1-james.morse@arm.com>
 <20180427153510.5799-2-james.morse@arm.com>
 <877eonr708.fsf@e105922-lin.cambridge.arm.com>
From: James Morse <james.morse@arm.com>
Message-ID: <4d3b63b0-66ad-8903-ea9a-6fa590a017d5@arm.com>
Date: Tue, 1 May 2018 13:50:43 +0100
MIME-Version: 1.0
In-Reply-To: <877eonr708.fsf@e105922-lin.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, jonathan.zhang@cavium.com

Hi Punit,

On 01/05/18 11:43, Punit Agrawal wrote:
> James Morse <james.morse@arm.com> writes:
>> Notes for cover letter:
>> ghes.c has three things all called 'estatus'. One is a pool of memory
>> that has a static size, and is grown/shrunk when new NMI users are
>> allocated.
>> The second is the cache, this holds recent notifications so we can
>> suppress notifications we've already handled.
>> The last is the queue, which hold data from NMI notifications (in pool
>> memory) that can't be handled immediatly.
> 
> 
> I am guessing you intended to drop the notes before sending the patch
> out.

Ha, oops!

> Calling this out as it'd make sense to clean-this up if the series is
> ready for merging.

Yes, thanks for calling that out.

I've deleted them now (copy-paste cover-letter serves the same purpose), so any
v4 will drop this.


Thanks,

James
