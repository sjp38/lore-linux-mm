Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92C78C4646D
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 07:16:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56F822083B
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 07:16:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56F822083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E66B06B0006; Sat, 29 Jun 2019 03:16:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E18BF8E0003; Sat, 29 Jun 2019 03:16:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D07318E0002; Sat, 29 Jun 2019 03:16:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f77.google.com (mail-ed1-f77.google.com [209.85.208.77])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1BA6B0006
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 03:16:42 -0400 (EDT)
Received: by mail-ed1-f77.google.com with SMTP id b33so11127817edc.17
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 00:16:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=zFtr0fJsS8OnyRIoY1LdPq7Hd6vLy+/ejAr9ILJtXWg=;
        b=LOLacMy2k1ECfZJXyy4STVWn4DuLblgA3vWoVOba/3N8ZyTXbvrSzQnLLN5DTmxqq8
         DTWln53nVGBxoM5cWdZhMkE14Df9POvQ/WiRHX761Vz1Wysy4tADesyaHdqZj4XtJ/lu
         1e+IX6HNf1Hg9u/SvhnIcHW3DNvt9JM0oQEbFWN/pnhBIojcyaqL2CeiHmj1ZmjFe1cb
         pUZIUPJElHw/MhkC+l+sMiIaTNctMwIhRe7MMU206k+N/mGsW1kK3K4m2IlPQErmdYio
         Dx8Km/2WOk9Tkd+qrjarRMJ3+PZblHXtHhtlsmiWdxNVgqcujj9CA8HpVbF/o5Qyex6J
         thEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAXOLci5OuGIPb2CmEtKI36OqvfbfoE7eQ0EJy1waW8ssY4e83wh
	KLYK2JJWyuRyJWIAN9KRmQje/i4HTGKZdlVpe7jHdaIMoyv6tE7WckxmebI+29TX2U7knOFqlrs
	LK0lbFAjzXzxg4morJlaSQltGNQ8hfFnOlSn8CfD1kBUPfhycBj319W6LO+ObHEDRYw==
X-Received: by 2002:aa7:c486:: with SMTP id m6mr16180578edq.298.1561792602006;
        Sat, 29 Jun 2019 00:16:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw71zaWF3JgQA+rTyZww8CaVq1qFmP+KL6oV4CGttR0BVjrORhijjkgErUrT+7I1yo//ta4
X-Received: by 2002:aa7:c486:: with SMTP id m6mr16180495edq.298.1561792600863;
        Sat, 29 Jun 2019 00:16:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561792600; cv=none;
        d=google.com; s=arc-20160816;
        b=n+1our5viSEoPK5z0DYHDLvg6a5ev3Oh6EXPVhy2T2buhC+x4HTnGKPVyraLNEdAxE
         zoA50qs1pNbBfrUQ/ELUK5ktPypd/CxaXIb9ePutpC3MAA9SFY58E/Y7nMpTvALG3ut8
         HMdLgdU4uiDeTPoeiJy1HTeWE1rmqyuFvUG+NUY6LeUiTJ05BTtVylR4A5gF4npo4voN
         XmiROg2rFyI+z2APkVRlpMHiwwwOwhahYxTRCiikWR0Gvsag0XQBJTURIhQo5pkyvDQ7
         tU9HJq3L9yUdhSnLZmS3ajunbrc+oXwWJemFu9lvhAjYCCkaWcaupG7b4Ryag5aLUiUA
         RW6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=zFtr0fJsS8OnyRIoY1LdPq7Hd6vLy+/ejAr9ILJtXWg=;
        b=azPBdnCj/8DsyVbguxtxl668eOqQbJSxhnAG1stV/z2LOhnWLDFP994ykSpmNZrnVw
         41GNmcm8SBXom2S9vmBCe2tEtFyNPYDF5u62ZN0qw7JROYNtpNJXToNtyjCQp5Y090ez
         xV8IoMaoxw+hga2N0KrE1BB5ESCWT4NpnD4c+5P40YNIK1QKohuPRy+dVLY4Y62m0Q3H
         +G3uDxaMqJrsACf0+ajTa5MxLhEdNC5WlDzGEthp3bElJwMcrMBIJqZAuv0uvLwOHq9m
         NCQX2Rw+DFyJSaAWHDPU9uG6LsoDpxOQzCx8Id6RnyjZddotYXUBQOnYn2uvRht6HK2E
         A7Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id n17si2878221ejb.18.2019.06.29.00.16.39
        for <linux-mm@kvack.org>;
        Sat, 29 Jun 2019 00:16:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vincenzo.frascino@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D18B228;
	Sat, 29 Jun 2019 00:16:38 -0700 (PDT)
Received: from [192.168.1.18] (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E66EA3F246;
	Sat, 29 Jun 2019 00:18:27 -0700 (PDT)
Subject: Re: [RFC] arm64: Detecting tagged addresses
To: Andrew Murray <andrew.murray@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Dan Carpenter <dan.carpenter@oracle.com>, smatch@vger.kernel.org
References: <20190619121619.GV20984@e119886-lin.cambridge.arm.com>
 <20190626174502.GH29672@arrakis.emea.arm.com>
 <20190627131834.GE34530@e119886-lin.cambridge.arm.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <0887dbcd-0b38-9f58-c2b7-d0b2dabf58cb@arm.com>
Date: Sat, 29 Jun 2019 08:17:28 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190627131834.GE34530@e119886-lin.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+ Dan and smatch@vger.kernel.org

Hi Andrew,

I am adding Dan to this thread since he is the smatch maintainer, and the
smatch@vger.kernel.org list.

@Dan and @smatch@vger.kernel.org: a reference to the beginning of this thread
can be found at [1].

[1] https://lkml.org/lkml/2019/6/19/376

On 6/27/19 2:18 PM, Andrew Murray wrote:
> On Wed, Jun 26, 2019 at 06:45:03PM +0100, Catalin Marinas wrote:
>> Hi Andrew,
>>
>> Cc'ing Luc (sparse maintainer) who's been involved in the past
>> discussions around static checking of user pointers:
>>
>> https://lore.kernel.org/linux-arm-kernel/20180905190316.a34yycthgbamx2t3@ltop.local/
>>
>> So I think the difference here from the previous approach is that we
>> explicitly mark functions that cannot take tagged addresses (like
>> find_vma()) and identify the callers.
> 
> Indeed.
> 
> 
>>
>> More comments below:
>>
>> On Wed, Jun 19, 2019 at 01:16:20PM +0100, Andrew Murray wrote:
>>> The proposed introduction of a relaxed ARM64 ABI [1] will allow tagged memory
>>> addresses to be passed through the user-kernel syscall ABI boundary. Tagged
>>> memory addresses are those which contain a non-zero top byte (the hardware
>>> has always ignored this top byte due to TCR_EL1.TBI0) and may be useful
>>> for features such as HWASan.
>>>
>>> To permit this relaxation a proposed patchset [2] strips the top byte (tag)
>>> from user provided memory addresses prior to use in kernel functions which
>>> require untagged addresses (for example comparasion/arithmetic of addresses).
>>> The author of this patchset relied on a variety of techniques [2] (such as
>>> grep, BUG_ON, sparse etc) to identify as many instances of possible where
>>> tags need to be stipped.
>>>
>>> To support this effort and to catch future regressions (e.g. in new syscalls
>>> or ioctls), I've devised an additional approach for detecting the use of
>>> tagged addresses in functions that do not want them. This approach makes
>>> use of Smatch [3] and is outlined in this RFC. Due to the ability of Smatch
>>> to do flow analysis I believe we can annotate the kernel in fewer places
>>> than a similar approach in sparse.
>>>
>>> I'm keen for feedback on the likely usefulness of this approach.
>>>
>>> We first add some new annotations that are exclusively consumed by Smatch:
>>>
>>> --- a/include/linux/compiler_types.h
>>> +++ b/include/linux/compiler_types.h
>>> @@ -19,6 +19,7 @@
>>>  # define __cond_lock(x,c)      ((c) ? ({ __acquire(x); 1; }) : 0)
>>>  # define __percpu      __attribute__((noderef, address_space(3)))
>>>  # define __rcu         __attribute__((noderef, address_space(4)))
>>> +# define __untagged    __attribute__((address_space(5)))
>>>  # define __private     __attribute__((noderef))
>>>  extern void __chk_user_ptr(const volatile void __user *);
>>>  extern void __chk_io_ptr(const volatile void __iomem *);
>> [...]
>>> --- a/mm/mmap.c
>>> +++ b/mm/mmap.c
>>> @@ -2224,7 +2224,7 @@ get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
>>>  EXPORT_SYMBOL(get_unmapped_area);
>>>  
>>>  /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
>>> -struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
>>> +struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long __untagged addr)
>>>  {
>>>         struct rb_node *rb_node;
>>>         struct vm_area_struct *vma;
>> [...]
>>> This can be further improved - the problem here is that for a given function,
>>> e.g. find_vma we look for callers where *any* of the parameters
>>> passed to find_vma are tagged addresses from userspace - i.e. not *just*
>>> the annotated parameter. This is also true for find_vma's callers' callers'.
>>> This results in the call tree having false positives.
>>>
>>> It *is* possible to track parameters (e.g. find_vma arg 1 comes from arg 3 of
>>> do_pages_stat_array etc), but this is limited as if functions modify the
>>> data then the tracking is stopped (however this can be fixed).
>> [...]
>>> An example of a false positve is do_mlock. We untag the address and pass that
>>> to apply_vma_lock_flags - however we also pass a length - because the length
>>> came from userspace and could have the top bits set - it's flagged. However
>>> with improved parameter tracking we can remove this false positive and similar.
>>
>> Could we track only the conversions from __user * that eventually end up
>> as __untagged? (I'm not familiar with smatch, so not sure what it can
>> do).
> 
> I assume you mean 'that eventually end up as an argument annotated __untagged'?
> 
> The warnings smatch currently produce relate to only the conversions you
> mention - however further work is needed in smatch to improve the scripts that
> retrospectively provide call traces (without false positives).
> 
> 
>> We could assume that an unsigned long argument to a syscall is
>> default __untagged, unless explicitly marked as __tagged. For example,
>> sys_munmap() is allowed to take a tagged address.
> 
> I'll give this some further thought.
> 
> 
>>
>>> Prior to smatch I attempted a similar approach with sparse - however it seemed
>>> necessary to propogate the __untagged annotation in every function up the call tree,
>>> and resulted in adding the __untagged annotation to functions that would never
>>> get near user provided data. This leads to a littering of __untagged all over the
>>> kernel which doesn't seem appealing.
>>
>> Indeed. We attempted this last year (see the above thread).
>>
>>> Smatch is more capable, however it almost
>>> certainly won't pick up 100% of issues due to the difficulity of making flow
>>> analysis understand everything a compiler can.
>>>
>>> Is it likely to be acceptable to use the __untagged annotation in user-path
>>> functions that require untagged addresses across the kernel?
>>
>> If it helps with identifying missing untagged_addr() calls, I would say
>> yes (as long as we keep them to a minimum).
> 
> Thanks for the feedback.
> 
> Andrew Murray
> 
>>
>>> [1] https://lkml.org/lkml/2019/6/13/534
>>> [2] https://patchwork.kernel.org/cover/10989517/
>>> [3] http://smatch.sourceforge.net/
>>
>> -- 
>> Catalin

-- 
Regards,
Vincenzo

