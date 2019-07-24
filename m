Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AB24C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:35:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C44E22ADA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:35:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C44E22ADA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 999526B0008; Wed, 24 Jul 2019 09:35:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 949746B000A; Wed, 24 Jul 2019 09:35:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8395C8E0002; Wed, 24 Jul 2019 09:35:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 381636B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 09:35:40 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d27so30228741eda.9
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 06:35:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LkCUzc18basGUDp6OqoEbeqDJDPyww5tVbHDdIoUd5k=;
        b=CtK4wCvXuCjID6C8pGsB/LFbqgfbi0ZuIr46ejscP/MN7Ku7VPWQA7mIkJTELxUawb
         CyhMeSDEb5UpwL3AsRPGLhPtmtLGhNY9lWnMrTYy7JlPdBdm+KX7mgS8cf1iyoWTg8Fh
         Oyc0esXtxQ/bfiyqyCABPgCfoOpKhy/X9EngurphoIXlj0vu47zthFNAbGN0qevlGcuO
         jx98lp1C1/SbBulopLQ7hyiVcOa7m1qM9rwVc4ArdR6olEcAeBdvjJfdrI/rN+skYxrM
         TOPjswzLDRNNhfuSzpLLvc1xHJwrSqgv9T44my86pzzCjH1UIsRvXRczGVA9Ao9My+gR
         DPKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUVIxb5PYmqj8PCIfmTwT89PsVgV72dPLbYxu4ku7WN5pQMCEBa
	1qkHMgXnPrbs3BSQnvgqGIrvanx//+61jfwQP2GMwqiSmz1y4PKGJAcyt4CtCBdN64zDLb8eYbx
	qVFokVPfm6gs9Wl8CJJy5tZ59ck6gHlWF0Erg7qg5TyU9/JZxcjvULJzboOGYEuaSWg==
X-Received: by 2002:a17:907:2114:: with SMTP id qn20mr62938727ejb.138.1563975339766;
        Wed, 24 Jul 2019 06:35:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwn/hz00WAJzSW8qfp2lB9QU6dZ3oyQEOQzX99KEXeBwT2juqnrlVQksadPJKPkrG5PNQJ7
X-Received: by 2002:a17:907:2114:: with SMTP id qn20mr62938663ejb.138.1563975338944;
        Wed, 24 Jul 2019 06:35:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563975338; cv=none;
        d=google.com; s=arc-20160816;
        b=vgFHgIi3IBcan2WxYtg8ILZPnbiteEylvQwFNh2axBAVXmzFbL/1gERiLTY0hsew7a
         K/ohxB0odFTktAW83jE4HgkWl/66zz5Hn0daiQx6Y2uPJp7usOB9kcIusI+BFMa/fcJt
         NhNRNYJ8Pq0G9HFMrcW71sv9fWmC8vRus3Y6kw9mMP+oTd6bVm4XeWkEQW+N+g9CaG4g
         NizgOHyT7m5p8djQ/IeexzvVaY24AfVQOqNL0Pw7sp2UQ8SQt0LHFkt2/fD1EaBm625Q
         Di3P9XE47MAutuStm1c1Yx6bRapRt4wq718FdJstYCpsIELhIgpK3BMwF8xuBlYBgbbb
         I67w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=LkCUzc18basGUDp6OqoEbeqDJDPyww5tVbHDdIoUd5k=;
        b=FGRBq1Tsr8WGY/5lSmbp+8JvryUkqlekzoe6NBWBjEp/cyAGwlduZIv+M9TAPmUKPC
         2kfZydXPD90q+glJvOuS9J0havwGFpZS19J8/MD+8/+yzOQ5oxk5wouDHwydgLM++fmc
         Nty35+N8/3JM4XyX8QOepQEa8sqxA4yJ3Bh7QhNQ2NiSiMm7tl7AzT5mHJhDMpnnrtba
         rUjlmWCJpsqbvPzImChhQEzfhHx8rGfbdc8xTdPYwivAhg7PqOLwQD7Qrd930MUwZLJ9
         zfQt9j5Be5+HcbEPleTMrQmU0eJBupVdtxZvjx/ixlxf62I0HHl6LtquXkzeApXi7RqU
         66Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id k6si8582303edd.325.2019.07.24.06.35.38
        for <linux-mm@kvack.org>;
        Wed, 24 Jul 2019 06:35:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E512F28;
	Wed, 24 Jul 2019 06:35:37 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7FA4B3F71A;
	Wed, 24 Jul 2019 06:35:35 -0700 (PDT)
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
To: Mark Rutland <mark.rutland@arm.com>
Cc: x86@kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Will Deacon <will@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190723101639.GD8085@lakrids.cambridge.arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <e108b8a6-deca-e69c-b338-52a98b14be86@arm.com>
Date: Wed, 24 Jul 2019 14:35:34 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723101639.GD8085@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 23/07/2019 11:16, Mark Rutland wrote:
> On Mon, Jul 22, 2019 at 04:41:49PM +0100, Steven Price wrote:
>> This is a slight reworking and extension of my previous patch set
>> (Convert x86 & arm64 to use generic page walk), but I've continued the
>> version numbering as most of the changes are the same. In particular
>> this series ends with a generic PTDUMP implemention for arm64 and x86.
>>
>> Many architectures current have a debugfs file for dumping the kernel
>> page tables. Currently each architecture has to implement custom
>> functions for this because the details of walking the page tables used
>> by the kernel are different between architectures.
>>
>> This series extends the capabilities of walk_page_range() so that it can
>> deal with the page tables of the kernel (which have no VMAs and can
>> contain larger huge pages than exist for user space). A generic PTDUMP
>> implementation is the implemented making use of the new functionality of
>> walk_page_range() and finally arm64 and x86 are switch to using it,
>> removing the custom table walkers.
>>
>> To enable a generic page table walker to walk the unusual mappings of
>> the kernel we need to implement a set of functions which let us know
>> when the walker has reached the leaf entry. After a suggestion from Will
>> Deacon I've chosen the name p?d_leaf() as this (hopefully) describes
>> the purpose (and is a new name so has no historic baggage). Some
>> architectures have p?d_large macros but this is easily confused with
>> "large pages".
>>
>> Mostly this is a clean up and there should be very little functional
>> change. The exceptions are:
>>
>> * x86 PTDUMP debugfs output no longer display pages which aren't
>>   present (patch 14).
>>
>> * arm64 has the ability to efficiently process KASAN pages (which
>>   previously only x86 implemented). This means that the combination of
>>   KASAN and DEBUG_WX is now useable.
> 
> Are there any visible changes to the arm64 output?

arm64 output shouldn't change. I've confirmed that "efi_page_tables" is
identical on a Juno before/after the change. "kernel_page_tables"
obviously will vary depending on the exact layout of memory, but the
format isn't changed.

x86 output does change due to patch 14. In this case the change is
removing the lines from the output of the form...

> 0xffffffff84800000-0xffffffffa0000000         440M                               pmd

...which are unpopulated areas of the memory map. Populated lines which
have attributes are unchanged.

Steve

