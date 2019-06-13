Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C48CC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:16:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DBE620B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:16:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DBE620B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A64D86B026C; Thu, 13 Jun 2019 07:16:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A15A06B026F; Thu, 13 Jun 2019 07:16:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92CCA6B0270; Thu, 13 Jun 2019 07:16:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 432FD6B026C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 07:16:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so23119343eds.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 04:16:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5brVy+vYqJCDIvgFEVq0ycxtCIHRj4uza4aeHpPoN8Q=;
        b=p06hC8GKoJ9pPXXGyOxUPpuWX6zxyi8fmt1RZAozUZ6colvDvebVQxxRRwYyUqEDfB
         5Eoew15uGfERz5Kdx0jPwF0+GwRW3VMJIQ9/Q/QQGRnIu6QEG71ZvWgko5eia2BWKbP0
         PNPzBW7n4xCJsMw1VuUplE7N1ty/0fWWdhR3XSou5igMoYHDxP+oNb3FjIC2TUU96964
         2p7XsQK9e4ETWo6D0KxFIWcUfe8O94X/8JYASGA+Zd6NuFRnrBV4Pt4nuiKkDMwkYqQJ
         jXo6OW0fttYACpC8Wp+NU6bUwt7fX3sUOrVqcEPFQDqDOVfX+tdcpAnAPqvXVxxECKkF
         o3Yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAVbV8nNiiGbUGee1cKmd7b+srjVsZf0dxHjIKZz8xpI2MrPhEsS
	G+hwULMWM4OteFGHa5H7UWU4WTWtpXGBm4hpgbLElZAJXl1MFWiU97ukWJyLExkqhry+hazz5Cj
	zHf3j8ubbZnV3jhLmuEfEsGREHn1NSepCnvtvVuqQVR8CNABjGnLovxBGudz43gwwYQ==
X-Received: by 2002:a17:906:604e:: with SMTP id p14mr30976650ejj.192.1560424589792;
        Thu, 13 Jun 2019 04:16:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzS1jWl9ZpZOVYqt2k5/rHNbzbIpLserxaAa18g9jnzBNTimvfKyjWdL1HFLr5pxfyyKaTJ
X-Received: by 2002:a17:906:604e:: with SMTP id p14mr30976552ejj.192.1560424588615;
        Thu, 13 Jun 2019 04:16:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560424588; cv=none;
        d=google.com; s=arc-20160816;
        b=UtnPpeaZDFg2J4694Vs6Hzib+OiewqMihxl0rNkj3dTJfuqUc6qN9eHpKvE+TjqD0u
         O5/iJEDq3+SBVttp3SRNThaTIxW2LWCQF6IwATKjjoycdAXa5r6P6Zuonw5KVi6+01XZ
         3ttlzEFRgSRxhT+4EmxpShtRz21lsp6KLeRh7EoF4a72BhRyQYkMuj3X+80Htfx56nVI
         X1H/afN7diWJwTkwew7mv7iLj6B9eN124S5MYqEi6Z+a3TIoUsGRYzdjyNUuHdhN842n
         9wJ2fK9rjyuQ73x+P19BKiE2OhjhG/fNnaR+sKfnJ7/Ps21GIjHlubpzIKVVwlpSa0VX
         qVqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=5brVy+vYqJCDIvgFEVq0ycxtCIHRj4uza4aeHpPoN8Q=;
        b=uj10Isa1Z/EP8XJRkUmK+1g5tyeBEuooKVzFmCJqtmCajaH5RtzxTnLLmy54PbEFSD
         e8+zg+joogjksGKLbF8I146stUNGkZvMFnf395NzQrHSfny/0Ngft3KM7joztG7GvDZR
         ku8cW+QQKW5ZnTRsq2842uuWLRZhfwcpwO7P8qPypCsCpeH7z2U8/M4TuJLS26Ll6I2x
         hENepnUepdC4pxKEEeLzYy1ZScioGap17UmWXDYi2ZbCBl3axhJgnkfdP8+EGKWztHNS
         ajWq/qbYDqrDtahtgzIY5dTglh50vSzITXu034PJWW+nF7p8Df8ra4mW4x8QM7Znt+sV
         Yb6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l17si2109469eda.278.2019.06.13.04.16.28
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 04:16:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A9840367;
	Thu, 13 Jun 2019 04:16:27 -0700 (PDT)
Received: from [10.1.196.72] (e119884-lin.cambridge.arm.com [10.1.196.72])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 152F93F694;
	Thu, 13 Jun 2019 04:18:08 -0700 (PDT)
Subject: Re: [PATCH v4 1/2] arm64: Define
 Documentation/arm64/tagged-address-abi.txt
To: Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
 Catalin Marinas <Catalin.Marinas@arm.com>
Cc: nd <nd@arm.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
 "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
 "linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Will Deacon <Will.Deacon@arm.com>, Andrey Konovalov <andreyknvl@google.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190612142111.28161-1-vincenzo.frascino@arm.com>
 <20190612142111.28161-2-vincenzo.frascino@arm.com>
 <a90da586-8ff6-4bed-d940-9306d517a18c@arm.com>
 <20190613092054.GO28951@C02TF0J2HF1T.local>
 <dee7f192-d0f0-558e-3007-eba805c6f2da@arm.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <6ebbda37-5dd9-d0d5-d9cb-286c7a5b7f8e@arm.com>
Date: Thu, 13 Jun 2019 12:16:24 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <dee7f192-d0f0-558e-3007-eba805c6f2da@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Szabolcs,

thank you for your review.

On 13/06/2019 11:14, Szabolcs Nagy wrote:
> On 13/06/2019 10:20, Catalin Marinas wrote:
>> Hi Szabolcs,
>>
>> On Wed, Jun 12, 2019 at 05:30:34PM +0100, Szabolcs Nagy wrote:
>>> On 12/06/2019 15:21, Vincenzo Frascino wrote:
>>>> +2. ARM64 Tagged Address ABI
>>>> +---------------------------
>>>> +
>>>> +From the kernel syscall interface prospective, we define, for the purposes
>>>                                      ^^^^^^^^^^^
>>> perspective
>>>
>>>> +of this document, a "valid tagged pointer" as a pointer that either it has
>>>> +a zero value set in the top byte or it has a non-zero value, it is in memory
>>>> +ranges privately owned by a userspace process and it is obtained in one of
>>>> +the following ways:
>>>> +  - mmap() done by the process itself, where either:
>>>> +    * flags = MAP_PRIVATE | MAP_ANONYMOUS
>>>> +    * flags = MAP_PRIVATE and the file descriptor refers to a regular
>>>> +      file or "/dev/zero"
>>>
>>> this does not make it clear if MAP_FIXED or other flags are valid
>>> (there are many map flags i don't know, but at least fixed should work
>>> and stack/growsdown. i'd expect anything that's not incompatible with
>>> private|anon to work).
>>
>> Just to clarify, this document tries to define the memory ranges from
>> where tagged addresses can be passed into the kernel in the context
>> of TBI only (not MTE); that is for hwasan support. FIXED or GROWSDOWN
>> should not affect this.
> 
> yes, so either the text should list MAP_* flags that don't affect
> the pointer tagging semantics or specify private|anon mapping
> with different wording.
> 

Good point. Could you please propose a wording that would be suitable for this case?

>>>> +  - a mapping below sbrk(0) done by the process itself
>>>
>>> doesn't the mmap rule cover this?
>>
>> IIUC it doesn't cover it as that's memory mapped by the kernel
>> automatically on access vs a pointer returned by mmap(). The statement
>> above talks about how the address is obtained by the user.
> 
> ok i read 'mapping below sbrk' as an mmap (possibly MAP_FIXED)
> that happens to be below the heap area.
> 
> i think "below sbrk(0)" is not the best term to use: there
> may be address range below the heap area that can be mmapped
> and thus below sbrk(0) and sbrk is a posix api not a linux
> syscall, the libc can implement it with mmap or whatever.
> 
> i'm not sure what the right term for 'heap area' is
> (the address range between syscall(__NR_brk,0) at
> program startup and its current value?)
> 

I used sbrk(0) with the meaning of "end of the process's data segment" not
implying that this is a syscall, but just as a useful way to identify the mapping.
I agree that it is a posix function implemented by libc but when it is used with
0 finds the current location of the program break, which can be changed by brk()
and depending on the new address passed to this syscall can have the effect of
allocating or deallocating memory.

Will changing sbrk(0) with "end of the process's data segment" make it more clear?

I will add what you are suggesting about the heap area.

>>>> +  - any memory mapped by the kernel in the process's address space during
>>>> +    creation and following the restrictions presented above (i.e. data, bss,
>>>> +    stack).
>>>
>>> OK.
>>>
>>> Can a null pointer have a tag?
>>> (in case NULL is valid to pass to a syscall)
>>
>> Good point. I don't think it can. We may change this for MTE where we
>> give a hint tag but no hint address, however, this document only covers
>> TBI for now.
> 
> OK.
> 
>>>> +The ARM64 Tagged Address ABI is an opt-in feature, and an application can
>>>> +control it using the following prctl()s:
>>>> +  - PR_SET_TAGGED_ADDR_CTRL: can be used to enable the Tagged Address ABI.
>>>> +  - PR_GET_TAGGED_ADDR_CTRL: can be used to check the status of the Tagged
>>>> +                             Address ABI.
>>>> +
>>>> +As a consequence of invoking PR_SET_TAGGED_ADDR_CTRL prctl() by an applications,
>>>> +the ABI guarantees the following behaviours:
>>>> +
>>>> +  - Every current or newly introduced syscall can accept any valid tagged
>>>> +    pointers.
>>>> +
>>>> +  - If a non valid tagged pointer is passed to a syscall then the behaviour
>>>> +    is undefined.
>>>> +
>>>> +  - Every valid tagged pointer is expected to work as an untagged one.
>>>> +
>>>> +  - The kernel preserves any valid tagged pointers and returns them to the
>>>> +    userspace unchanged in all the cases except the ones documented in the
>>>> +    "Preserving tags" paragraph of tagged-pointers.txt.
>>>
>>> OK.
>>>
>>> i guess pointers of another process are not "valid tagged pointers"
>>> for the current one, so e.g. in ptrace the ptracer has to clear the
>>> tags before PEEK etc.
>>
>> Another good point. Are there any pros/cons here or use-cases? When we
>> add MTE support, should we handle this differently?
> 
> i'm not sure what gdb does currently, but it has
> an 'address_significant' hook used at a few places
> that drops the tag on aarch64, so it probably
> avoids passing tagged pointer to ptrace.
> 
> i was worried about strace which tries to print
> structs passed to syscalls and follow pointers in
> them which currently would work, but if we allow
> tags in syscalls then it needs some update.
> (i haven't checked the strace code though)
>>>>> +A definition of the meaning of tagged pointers on arm64 can be found in:
>>>> +Documentation/arm64/tagged-pointers.txt.
>>>> +
>>>> +3. ARM64 Tagged Address ABI Exceptions
>>>> +--------------------------------------
>>>> +
>>>> +The behaviours described in paragraph 2, with particular reference to the
>>>> +acceptance by the syscalls of any valid tagged pointer are not applicable
>>>> +to the following cases:
>>>> +  - mmap() addr parameter.
>>>> +  - mremap() new_address parameter.
>>>> +  - prctl_set_mm() struct prctl_map fields.
>>>> +  - prctl_set_mm_map() struct prctl_map fields.
>>>
>>> i don't understand the exception: does it mean that passing a tagged
>>> address to these syscalls is undefined?
>>
>> I'd say it's as undefined as it is right now without these patches. We
>> may be able to explain this better in the document.
>>
> 

-- 
Regards,
Vincenzo

