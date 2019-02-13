Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49446C282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 16:42:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0D4E222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 16:42:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0D4E222C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 353298E0002; Wed, 13 Feb 2019 11:42:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DC4E8E0001; Wed, 13 Feb 2019 11:42:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17E358E0002; Wed, 13 Feb 2019 11:42:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id ACC998E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 11:42:21 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d9so1252843edl.16
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:42:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=BHtOYUlEg+/zN0Hfk5xaIqxkGXpecxWeuMTPfjrfqRM=;
        b=atHP9xU6EcNFRow+ZF1YJliRCmG5KY5Moe7jCn84sNpZqOs7llJ00hetK51EtbCnyM
         pa1zQouqbAx4ZOdF7Fjc8M/HtIs8TIE8YJoAbor6u4N+K5IkvkA4OCjJJeV5l3TgoymT
         uEa9Ah/hk6bCenNUD/e38f8KSa7XZwbtiak4HvxPcWh+efkO3EnIoI3n+b8rSEsIPHDR
         cqZhnXi/9MH3ZVfdwUlP3CSUCqUJfoyR26lnUMmtzo4T/6qoAyORLG/cEqip0BsX0OnJ
         CughwifpAPUNSnjuO5GIAOeuaDMfcAkR3JrSei5E5EEvISWC2VpmPu5xl8Xu9dcdDFDo
         nhDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
X-Gm-Message-State: AHQUAua4kJVI1JGg2V33woNJk1YDiawkzswxD2PTn13Fq/XisolmsEp7
	ZaiqRYJOGyBarQjfJUgVwuqdg8dGgkF5ORKIZWe/F88jxkraL+1cIxHXmudpkWVOn2rt15McJsw
	n+p0BYOxjiqtv9pWV7CR1hZ41/g7N6MJGnrxbwAja5iLMJwKNsnc9O77wM5L/1ebEOQ==
X-Received: by 2002:a50:f709:: with SMTP id g9mr1075613edn.118.1550076141196;
        Wed, 13 Feb 2019 08:42:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYCJNRzW/GfMl0rqf/JFrB1tS53UBzKIqOk9n3RaanuUn04zjU+0KkF9Kg2uJA2j2bP5pLf
X-Received: by 2002:a50:f709:: with SMTP id g9mr1075545edn.118.1550076139925;
        Wed, 13 Feb 2019 08:42:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550076139; cv=none;
        d=google.com; s=arc-20160816;
        b=os6honpuaad25Tsbyw2Zatu2vBHRaYu9+CNKZqpIDkib2XlkfcpoNH5mSR9Ow52Zgh
         vFtZNgGgKJ/chclItRXe+pR+Vbzf4zYF+dKqNygwUQPRMZbEOWeWpJwX/4S3t6wRDEvy
         uGF+imxvULSV2IF+t3oi/jFIaDoyi5p8yiv3RKSxsapCX0a4sDgswiI75KLyNY13qDLT
         AEUWizNIE6YX/Ps50X8bzWwWl+TlONkysAOrGZrYm1L1osSAlmjJHP+HHCauVtBgwuP5
         nhtHa34kJs/oPfv7Ud8NjpZJSkHlSQDMzcsDObCNqrgTqWcV7Lk2ip96L6cl4o9set9V
         Kmdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=BHtOYUlEg+/zN0Hfk5xaIqxkGXpecxWeuMTPfjrfqRM=;
        b=yELTr6XFQq4BbdIGCZQ0lSpME6422MAZsIQXIxPcV5FHp5TH0Qt1w9+OGD5e2rfmAo
         lSR936sNzQrxPA0CMRh1bA1MkXE2clYN6UeathlRoyuTZNOBIGMRvdA5Tr/+sCZ4pPAN
         R/96bdLhevRcQqs/nR18jcAPc2DaN3VWL1WkMT+4prNO4nkoYxYk5GNPvrdhX5IaNuaN
         aSbdQJvfRpmYwks4ilW6L/89FTePvriUnbn0DpR1AKj9eQfna2sA5RiEMA6IGlBXdhvP
         h817hT1zDtowmNLQAAy7OhtCgKpeHV0uGVP8ln/fm2jc7Er2Nej/4h7VHoYltTmSDmbn
         8Zvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g5-v6si2394082ejp.46.2019.02.13.08.42.19
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 08:42:19 -0800 (PST)
Received-SPF: pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kevin.brodsky@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=kevin.brodsky@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6D151A78;
	Wed, 13 Feb 2019 08:42:18 -0800 (PST)
Received: from [10.1.199.35] (e107154-lin.cambridge.arm.com [10.1.199.35])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 81F753F675;
	Wed, 13 Feb 2019 08:42:13 -0800 (PST)
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
To: Dave Martin <Dave.Martin@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>
Cc: Evgenii Stepanov <eugenis@google.com>, Mark Rutland
 <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>,
 "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
 Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>,
 "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Vincenzo Frascino <vincenzo.frascino@arm.com>, Shuah Khan
 <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>,
 linux-arch <linux-arch@vger.kernel.org>,
 Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Kees Cook <keescook@chromium.org>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Andrey Konovalov <andreyknvl@google.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>,
 Robin Murphy <robin.murphy@arm.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Branislav Rankov <Branislav.Rankov@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>
References: <cover.1544445454.git.andreyknvl@google.com>
 <20181210143044.12714-1-vincenzo.frascino@arm.com>
 <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com>
 <20181212150230.GH65138@arrakis.emea.arm.com>
 <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
 <20181218175938.GD20197@arrakis.emea.arm.com>
 <20181219125249.GB22067@e103592.cambridge.arm.com>
 <9bbacb1b-6237-f0bb-9bec-b4cf8d42bfc5@arm.com>
 <CAFKCwrhH5R3e5ntX0t-gxcE6zzbCNm06pzeFfYEN2K13c5WLTg@mail.gmail.com>
 <20190212180223.GD199333@arrakis.emea.arm.com>
 <20190213145834.GJ3567@e103592.cambridge.arm.com>
From: Kevin Brodsky <kevin.brodsky@arm.com>
Message-ID: <90c54249-00dd-f8dd-6873-6bb8615c2c8a@arm.com>
Date: Wed, 13 Feb 2019 16:42:11 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190213145834.GJ3567@e103592.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-GB
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(+Cc other people with MTE experience: Branislav, Ruben)

On 13/02/2019 14:58, Dave Martin wrote:
> On Tue, Feb 12, 2019 at 06:02:24PM +0000, Catalin Marinas wrote:
>> On Mon, Feb 11, 2019 at 12:32:55PM -0800, Evgenii Stepanov wrote:
>>> On Mon, Feb 11, 2019 at 9:28 AM Kevin Brodsky <kevin.brodsky@arm.com> wrote:
>>>> On 19/12/2018 12:52, Dave Martin wrote:
> [...]
>
>>>>>    * A single C object should be accessed using a single, fixed
>>>>>      pointer tag throughout its entire lifetime.
>>>> Agreed.  Allocators themselves may need to be excluded though,
>>>> depending on how they represent their managed memory.
>>>>
>>>>>    * Tags can be changed only when there are no outstanding pointers to
>>>>>      the affected object or region that may be used to access the object
>>>>>      or region (i.e., if the object were allocated from the C heap and
>>>>>      is it safe to realloc() it, then it is safe to change the tag; for
>>>>>      other types of allocation, analogous arguments can be applied).
>>>> Tags can only be changed at the point of deallocation/
>>>> reallocation.  Pointers to the object become invalid and cannot
>>>> be used after it has been deallocated; memory tagging allows to
>>>> catch such invalid usage.
>> All the above sound well but that's mostly a guideline on what a C
>> library can do. It doesn't help much with defining the kernel ABI.
>> Anyway, it's good to clarify the use-cases.
> My aim was to clarify the use case in userspace, since I wasn't directly
> involved in that.  The kernel ABI needs to be compatible with the the
> use case, but doesn't need to specify must of it.
>
> I'm wondering whether we can piggy-back on existing concepts.
>
> We could say that recolouring memory is safe when and only when
> unmapping of the page or removing permissions on the page (via
> munmap/mremap/mprotect) would be safe.  Otherwise, the resulting
> behaviour of the process is undefined.

Is that a sufficient requirement? I don't think that anything prevents you from using 
mprotect() on say [vvar], but we don't necessarily want to map [vvar] as tagged. I'm 
not sure it's easy to define what "safe" would mean here.

> Hopefully there are friendly fuzzers testing this kind of thing.
>
> [...]
>
>>> It would also be valuable to narrow down the set of "relaxed" (i.e.
>>> not tag-checking) syscalls as reasonably possible. We would want to
>>> provide tag-checking userspace wrappers for any important calls that
>>> are not checked in the kernel. Is it correct to assume that anything
>>> that goes through copy_from_user  / copy_to_user is checked?
>> I lost track of the context of this thread but if it's just about
>> relaxing the ABI for hwasan, the kernel has no idea of the compiler
>> generated structures in user space, so nothing is checked.
>>
>> If we talk about tags in the context of MTE, than yes, with the current
>> proposal the tag would be checked by copy_*_user() functions.
> Also put_user() and friends?
>
> It might be reasonable to do the check in access_ok() and skip it in
> __put_user() etc.
>
> (I seem to remember some separate discussion about abolishing
> __put_user() and friends though, due to the accident risk they pose.)

Keep in mind that with MTE, there is no need to do any explicit check when accessing 
user memory via a user-provided pointer. The tagged user pointer is directly passed 
to copy_*_user() or put_user(). If the load/store causes a tag fault, then it is 
handled just like a page fault (i.e. invoking the fixup handler). As far as I can 
tell, there's no need to do anything special in access_ok() in that case.

[The above applies to precise mode. In imprecise mode, some more work will be needed 
after the load/store to check whether a tag fault happened.]

>
>>> For aio* operations it would be nice if the tag was checked at the
>>> time of the actual userspace read/write, either instead of or in
>>> addition to at the time of the system call.
>> With aio* (and synchronous iovec-based syscalls), the kernel may access
>> the memory while the corresponding user process is scheduled out. Given
>> that such access is not done in the context of the user process (and
>> using the user VA like copy_*_user), the kernel cannot handle potential
>> tag faults. Moreover, the transfer may be done by DMA and the device
>> does not understand tags.
>>
>> I'd like to keep tags as a property of the pointer in a specific virtual
>> address space. The moment you convert it to a different address space
>> (e.g. kernel linear map, physical address), the tag property is stripped
>> and I don't think we should re-build it (and have it checked).
> This is probably reasonable.
>
> Ideally we would check the tag at the point of stripping it off, but
> most likely it's going to be rather best-effort.
>
> If memory tagging is essential a debugging feature then this seems
> an acceptable compromise.

There are many possible ways to deploy MTE, and debugging is just one of them. For 
instance, you may want to turn on heap colouring for some processes in the system, 
including in production.

Regarding those cases where it is impossible to check tags at the point of accessing 
user memory, it is indeed possible to check the memory tags at the point of stripping 
the tag from the user pointer. Given that some MTE use-cases favour performance over 
tag check coverage, the ideal approach would be to make these checks configurable 
(e.g. check one granule, check all of them, or check none). I don't know how feasible 
this is in practice.

Kevin

>
>>>>>    * For purposes other than dereference, the kernel shall accept any
>>>>>      legitimately tagged pointer (according to the above rules) as
>>>>>      identifying the associated memory location.
>>>>>
>>>>>      So, mprotect(some_page_aligned_object, ...); is valid irrespective
>>>>>      of where page_aligned_object() came from.  There is no implicit
>>>>>      derefence by the kernel here, hence no tag check.
>>>>>
>>>>>      The kernel does not guarantee to work correctly if the wrong tag
>>>>>      is used, but there is not always a well-defined "right" tag, so
>>>>>      we can't really guarantee to check it.  So a pointer derived by
>>>>>      any reasonable means by userspace has to be treated as equally
>>>>>      valid.
>>>> This is a disputed point :) In my opinion, this is the the most
>>>> reasonable approach.
>>> Yes, it would be nice if the kernel explicitly promised, ex.
>>> mprotect() over a range of differently tagged pages to be allowed
>>> (i.e. address tag should be unchecked).
>> I don't think mprotect() over differently tagged pages was ever a
>> problem. I originally asked that mprotect() and friends do not accept
>> tagged pointers since these functions deal with memory ranges rather
>> than dereferencing such pointer (the reason being minimal kernel
>> changes). However, given how complicated it is to specify an ABI, I came
>> to the conclusion that a pointer passed to such function should be
>> allowed to have non-zero top byte. It would be the kernel's
>> responsibility to strip it out as appropriate.
> I think that if the page range is all the same colour then it should be
> legitimate to pass a matching tag.
>
> But it doesn't seem reasonable for the kernel to require this.  If
> free() calls munmap(), the page(s) will contain possibly randomly-
> coloured garbage.  There's no correct tag to pass in such a case.
>
> The most obvious solution is just to ignore the tags passed by userspace
> to such syscalls.  This would imply that the kernel must explicitly
> strip it out, as you suggest.
>
> The number of affected syscalls is relatively small though.
>
> Cheers
> ---Dave

