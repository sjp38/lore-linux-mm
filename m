Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D281C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:16:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59D3B20850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:16:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59D3B20850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F16286B026D; Fri, 12 Apr 2019 10:16:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF0516B026E; Fri, 12 Apr 2019 10:16:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDDDC6B026F; Fri, 12 Apr 2019 10:16:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC976B026D
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 10:16:36 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s6so5030317edr.21
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:16:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=3MMU6aQ0kc9WSYs729+oGjeFb16eYqurWXI4diGGqtk=;
        b=fIwfY0h6GWKttcxNMwgVQmHeKl1fN31gFHF/Vk31y9jXKtWVmm/qekY7abNsP0SaYF
         QrPnuzFFhVmeVdVYU1Nn6Vr05MN7tJGPPY1tQitoz7Jis8XC0NQVjz6keScDUVOEByO/
         okextLHnbYOB66ZU1YLXF0gPWYR4F+xEQM4n0KlE5F4PBjDJUQDp4YRQspZPsHLUI9co
         s5M2h6Zi0IbpkF1dezlIBHAoPwyO+voVih/99Nf7dHw79FM8d9IW/aOxnjjOVLWYeEjA
         xLLR+A9QxszBYOqDMFJx9Pzg5+kZG7/USWTyJXuMUZ1zEfAr+3y6qDUBnPEKgm6NiOFu
         7jMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: APjAAAW2OVA3m21Hzs3JoUzYaRLZ3VJp1fgw1nksu4i3jLn73rFUplGR
	TW0SMtEbmMnm0CyS53DUVHOOHb9WfQ9zLlyuEIp0TcMmVTdJeV0U15sBoG/nhcmZqdPJtN++Y0+
	XL2qS/l4rspakm8nVGx7C+/sHGnVvGJ0TO/Hvd+sOXgpwmJfIxv8nlCKZBFQGwv56NQ==
X-Received: by 2002:a17:906:d72:: with SMTP id s18mr20088692ejh.111.1555078596042;
        Fri, 12 Apr 2019 07:16:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0ivew2c2TDwxBX7BlwniJqw64uprbWonu0VmbgRB2tbpI0LxN8LvcTw6R1U+drOKaRmKw
X-Received: by 2002:a17:906:d72:: with SMTP id s18mr20088633ejh.111.1555078594951;
        Fri, 12 Apr 2019 07:16:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555078594; cv=none;
        d=google.com; s=arc-20160816;
        b=ON2GCyKxM/pOLQlx7PJzFOkISMBXVQt6zRaJAdEL8WS52/Dwsu/rMHypRVLGM2BsH3
         Sc0ZCAqYS0fJXrzgi2cz8E0Nb1wmIhXpXfP/WFuvHabd6MwUjrgThKr40UDkGANVFion
         itcXTZEDAJwFVMB3ZDzoU+cIGlGSdbTk5GVF+QdaWoaSNNrF0HSfvIhROr7DHenzJoTj
         DVN3sSWm9zBmy95wlXlq4oMHtz3ZiFJbphXftiDW9reDXfNen2yc4jRL1v5+rV9Pqv+z
         m97EBlVdK7m3ukAwF2So0TXXUBhTNKnqOg/6MU0pJ0a6UVu+dnkj4judLoVbzqp+3m7r
         +6Ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=3MMU6aQ0kc9WSYs729+oGjeFb16eYqurWXI4diGGqtk=;
        b=PWdYAvRYalVJklgU8uTZ7ttJ4dBXJ7omZl+1uMZeXRTguQdT8prOk4ZErksV+1noHv
         9TvmnFrFFr1JLTBvVtGDx7kShX7Ys8DeJVXRA8mxVOfFQ5MvSw0MWo0/zLid934ypk+O
         8aZDRFSyPC32nxP96v4tijVjI7IK2TPED50AMyUC94hEThYhwgOl8pyNxz2y1dLI0FPR
         qn2NW83AoWrZYJmQiXGujJLcnsRoBNlu+h/V1IG7lIKwz24ceWwf4D1SyXmrpF8CzCbh
         NkWwAfaM29ip7A2esbQIuN3XB2PpU81DcofH+C9mTiuxG7z8qjsjUTIEClar6JemRGd7
         xwAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j24si157155edt.162.2019.04.12.07.16.34
        for <linux-mm@kvack.org>;
        Fri, 12 Apr 2019 07:16:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 72D17374;
	Fri, 12 Apr 2019 07:16:33 -0700 (PDT)
Received: from [10.1.199.35] (e107154-lin.cambridge.arm.com [10.1.199.35])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9D0813F557;
	Fri, 12 Apr 2019 07:16:23 -0700 (PDT)
Subject: Re: [PATCH v2 2/4] arm64: Define Documentation/arm64/elf_at_flags.txt
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>,
 linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org,
 Alexander Viro <viro@zeniv.linux.org.uk>, Alexei Starovoitov
 <ast@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 Andrey Konovalov <andreyknvl@google.com>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Branislav Rankov <Branislav.Rankov@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Daniel Borkmann <daniel@iogearbox.net>, Dave Martin <Dave.Martin@arm.com>,
 "David S. Miller" <davem@davemloft.net>, Dmitry Vyukov <dvyukov@google.com>,
 Eric Dumazet <edumazet@google.com>, Evgeniy Stepanov <eugenis@google.com>,
 Graeme Barnes <Graeme.Barnes@arm.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Ingo Molnar <mingo@kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>,
 Kate Stewart <kstewart@linuxfoundation.org>,
 Kees Cook <keescook@chromium.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Robin Murphy <robin.murphy@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Shuah Khan <shuah@kernel.org>,
 Steven Rostedt <rostedt@goodmis.org>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
 Will Deacon <will.deacon@arm.com>
References: <cover.1552679409.git.andreyknvl@google.com>
 <20190318163533.26838-1-vincenzo.frascino@arm.com>
 <20190318163533.26838-3-vincenzo.frascino@arm.com>
 <859341c2-b352-e914-312a-d3de652495b6@arm.com>
 <20190403165031.GE34351@arrakis.emea.arm.com>
From: Kevin Brodsky <kevin.brodsky@arm.com>
Message-ID: <d2292560-54cf-8dc3-da96-4ccdd72d090e@arm.com>
Date: Fri, 12 Apr 2019 15:16:19 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190403165031.GE34351@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/04/2019 17:50, Catalin Marinas wrote:
> On Fri, Mar 22, 2019 at 03:52:49PM +0000, Kevin Brodsky wrote:
>> On 18/03/2019 16:35, Vincenzo Frascino wrote:
>>> +2. Features exposed via AT_FLAGS
>>> +--------------------------------
>>> +
>>> +bit[0]: ARM64_AT_FLAGS_SYSCALL_TBI
>>> +
>>> +    On arm64 the TCR_EL1.TBI0 bit has been always enabled on the arm64
>>> +    kernel, hence the userspace (EL0) is allowed to set a non-zero value
>>> +    in the top byte but the resulting pointers are not allowed at the
>>> +    user-kernel syscall ABI boundary.
>>> +    When bit[0] is set to 1 the kernel is advertising to the userspace
>>> +    that a relaxed ABI is supported hence this type of pointers are now
>>> +    allowed to be passed to the syscalls, when these pointers are in
>>> +    memory ranges privately owned by a process and obtained by the
>>> +    process in accordance with the definition of "valid tagged pointer"
>>> +    in paragraph 3.
>>> +    In these cases the tag is preserved as the pointer goes through the
>>> +    kernel. Only when the kernel needs to check if a pointer is coming
>>> +    from userspace an untag operation is required.
>> I would leave this last sentence out, because:
>> 1. It is an implementation detail that doesn't impact this user ABI.
>> 2. It is not entirely accurate: untagging the pointer may be needed for
>> various kinds of address lookup (like finding the corresponding VMA), at
>> which point the kernel usually already knows it is a userspace pointer.
> I fully agree, the above paragraph should not be part of the user ABI
> document.
>
>>> +3. ARM64_AT_FLAGS_SYSCALL_TBI
>>> +-----------------------------
>>> +
>>> +From the kernel syscall interface prospective, we define, for the purposes
>>> +of this document, a "valid tagged pointer" as a pointer that either it has
>>> +a zero value set in the top byte or it has a non-zero value, it is in memory
>>> +ranges privately owned by a userspace process and it is obtained in one of
>>> +the following ways:
>>> +  - mmap() done by the process itself, where either:
>>> +    * flags = MAP_PRIVATE | MAP_ANONYMOUS
>>> +    * flags = MAP_PRIVATE and the file descriptor refers to a regular
>>> +      file or "/dev/zero"
>>> +  - a mapping below sbrk(0) done by the process itself
>> I don't think that's very clear, this doesn't say how the mapping is
>> obtained. Maybe "a mapping obtained by the process using brk() or sbrk()"?
> I think what we mean here is anything in the "[heap]" section as per
> /proc/*/maps (in the kernel this would be start_brk to brk).
>
>>> +  - any memory mapped by the kernel in the process's address space during
>>> +    creation and following the restrictions presented above (i.e. data, bss,
>>> +    stack).
>> With the rules above, the code section is included as well. Replacing "i.e."
>> with "e.g." would avoid having to list every single section (which is
>> probably not a good idea anyway).
> We could mention [stack] explicitly as that's documented in the
> Documentation/filesystems/proc.txt and it's likely considered ABI
> already.
>
> The code section is MAP_PRIVATE, and can be done by the dynamic loader
> (user process), so it falls under the mmap() rules listed above. I guess
> we could simply drop "done by the process itself" here and allow
> MAP_PRIVATE|MAP_ANONYMOUS or MAP_PRIVATE of regular file. This would
> cover the [heap] and [stack] and we won't have to debate the brk() case
> at all.

That's probably the best option. I initially used this wording because I was worried 
that there could be cases where the kernel allocates "magic" memory for userspace 
that is MAP_PRIVATE|MAP_ANONYMOUS, but in fact it's probably not the case (presumably 
such mapping should always be done via install_special_mapping(), which is definitely 
not MAP_PRIVATE).

> We probably mention somewhere (or we should in the tagged pointers doc)
> that we don't support tagged PC.

I think that Documentation/arm64/tagged-pointers.txt already makes it reasonably 
clear (anyway, with the architecture not supporting it, you can't expect much from 
the kernel).

Kevin

