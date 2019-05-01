Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61BD9C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 14:43:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2402E208C3
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 14:43:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2402E208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B99DE6B0005; Wed,  1 May 2019 10:43:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4AAC6B0006; Wed,  1 May 2019 10:43:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EADE6B0008; Wed,  1 May 2019 10:43:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8DA6B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 10:43:29 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o8so7924866edh.12
        for <linux-mm@kvack.org>; Wed, 01 May 2019 07:43:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=suhca6lb4katGIatZXXrEmb6+cGHeXo2yELfpUGBq4E=;
        b=gngVRLj9yPHQ2eX/rnC/wGfQIjPfRoaFF+QwjOkCrvftW8DUIjBYp5HgDVISh3UnLH
         IUDGez0IyH7Ujs6dblU1CnPwkgL5KC/OnS+q1YYEIJ6oQFcDs5EYbv708WIob6mITPfS
         fzjkEHH7L+zdsYSrsFXyF9/W78G5p+CFXanyda1u5wsN1/Jwy7gxBFp2Zbz8lx8UUnhe
         EsAUmw8bfBMY9jYWl1CggJB94eeeXW1FSCDcYWtN8WpjEhtlzOCT11C/6m0wkANjM58J
         opiwU9tpJHtUL3IoFvgxj/LuvSygBTex1WYpK14W+HleZ6m/rY3bIhcxzL9pMDkJy92a
         4A7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
X-Gm-Message-State: APjAAAVbbMcbpAW/STk88I6bKDyiYkIDW+kfQgVRMw37eGZwrQD5/O8+
	saQA6FnWSOu37WREvoFLRSfL0dgxlkA4d9rnIH3ukk+2J3pZWSZ5+Kdu9fqUwrK9s3Y2HlY3zkn
	VBEbTusp+3sLc61FcPO2kBs1ZWUI3Unuo1QT+510MyEabIDls5YSmMU5+aKvjTrEjVg==
X-Received: by 2002:aa7:c44e:: with SMTP id n14mr23173048edr.203.1556721808885;
        Wed, 01 May 2019 07:43:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwWgr4cizvzkY0Z06zYFAtbETh4f6ns6w4tJIXJhedZGGovQ57DagEAtr7v6QpvaBbhqER
X-Received: by 2002:aa7:c44e:: with SMTP id n14mr23172995edr.203.1556721807901;
        Wed, 01 May 2019 07:43:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556721807; cv=none;
        d=google.com; s=arc-20160816;
        b=UQ3NajgnXioa2/3AsRIfnAYJviEi1u7RKDZrQF0wm3wLmldtaase2bwB3taeCAd+E/
         dnXgRyxbrUoRh1PbK25L+xmXA/eko6HmX/DJQzPB8LnLa1pc54fnJHiS3xQA3DUH1QBi
         1Iwq0lQRcuwpXqdNte8d/TapNxlNT3KHGVJfo3bFsxKThLky+wKqr9aQh+D/qpiC+wmQ
         r4dVDaqSVhOM+6X7IIx5MJjyRYSeZsqn+i6zY6fzbcpQ7L8YUVji1boh8deC75hj/Pi8
         lh67OJMQBp6GaOx4UvhTNeX/k6/ToP8R6IAA/JcPILp3J8l1cnw6M4lMfAM4v+AI+bZs
         ejTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=suhca6lb4katGIatZXXrEmb6+cGHeXo2yELfpUGBq4E=;
        b=tCLHe7ITiueNys8gQ2B32Nj0tlCTTwSy6KRIKzRX9YmCAgn+f69nVsRHSJqfvs5S6c
         CXDS+tCwh0WtiaZqT9JZuBTvKXuWmcljZVBMSBpqFTrj5+LERrVHrpTzTZgfJBH/pCJb
         xJRZFtPghTvFRtjtkWabcLpgxekXyjLxasrkQ1ENuVQOKKcSBWvHMRQmEcZ+qStobezm
         8z0SQ2AcfHDk7srcbFakZ3d18HPVoveoBd3pBXjbpvtDTSnpT3hilXYN9DJKujvbsrlL
         gLleZikGXKYtaZ+qXxz8Te/QASr+2K/vRGcdiJHig74zA1jRIc/XiyKYUum7yhGAedSY
         d9tw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s50si2276553edd.184.2019.05.01.07.43.27
        for <linux-mm@kvack.org>;
        Wed, 01 May 2019 07:43:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of vincenzo.frascino@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=vincenzo.frascino@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8729EA78;
	Wed,  1 May 2019 07:43:26 -0700 (PDT)
Received: from [192.168.1.18] (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CE1D23F719;
	Wed,  1 May 2019 07:43:15 -0700 (PDT)
Subject: Re: [PATCH v13 10/20] kernel, arm64: untag user pointers in
 prctl_set_mm*
To: Andrey Konovalov <andreyknvl@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>,
 Kate Stewart <kstewart@linuxfoundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Shuah Khan <shuah@kernel.org>, Eric Dumazet <edumazet@google.com>,
 "David S. Miller" <davem@davemloft.net>, Alexei Starovoitov
 <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>,
 Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Arnaldo Carvalho de Melo <acme@kernel.org>,
 Alex Deucher <alexander.deucher@amd.com>,
 =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>,
 "David (ChunMing) Zhou" <David1.Zhou@amd.com>,
 Yishai Hadas <yishaih@mellanox.com>,
 Mauro Carvalho Chehab <mchehab@kernel.org>,
 Jens Wiklander <jens.wiklander@linaro.org>,
 Alex Williamson <alex.williamson@redhat.com>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 linux-arch <linux-arch@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
 bpf <bpf@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
 linux-media@vger.kernel.org, kvm@vger.kernel.org,
 "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>,
 Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>,
 Lee Smith <Lee.Smith@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>,
 Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <76f96eb9162b3a7fa5949d71af38bf8fdf6924c4.1553093421.git.andreyknvl@google.com>
 <20190322154136.GP13384@arrakis.emea.arm.com>
 <CAAeHK+yHp27eT+wTE3Uy4DkN8XN3ZjHATE+=HgjgRjrHjiXs3Q@mail.gmail.com>
 <20190426145024.GC54863@arrakis.emea.arm.com>
 <CAAeHK+ww=6-fTnHN_33EEiKdMqXq5bNU4oW9oOMcfz1N_+Kisw@mail.gmail.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <c00bde00-3026-7c01-df0e-b374582b5825@arm.com>
Date: Wed, 1 May 2019 15:43:28 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAAeHK+ww=6-fTnHN_33EEiKdMqXq5bNU4oW9oOMcfz1N_+Kisw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrey,

sorry for the late reply, I came back from holiday and try to catch up with the
emails.

On 4/29/19 3:23 PM, Andrey Konovalov wrote:
> On Fri, Apr 26, 2019 at 4:50 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>>
>> On Mon, Apr 01, 2019 at 06:44:34PM +0200, Andrey Konovalov wrote:
>>> On Fri, Mar 22, 2019 at 4:41 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>>>> On Wed, Mar 20, 2019 at 03:51:24PM +0100, Andrey Konovalov wrote:
>>>>> @@ -2120,13 +2135,14 @@ static int prctl_set_mm(int opt, unsigned long addr,
>>>>>       if (opt == PR_SET_MM_AUXV)
>>>>>               return prctl_set_auxv(mm, addr, arg4);
>>>>>
>>>>> -     if (addr >= TASK_SIZE || addr < mmap_min_addr)
>>>>> +     if (untagged_addr(addr) >= TASK_SIZE ||
>>>>> +                     untagged_addr(addr) < mmap_min_addr)
>>>>>               return -EINVAL;
>>>>>
>>>>>       error = -EINVAL;
>>>>>
>>>>>       down_write(&mm->mmap_sem);
>>>>> -     vma = find_vma(mm, addr);
>>>>> +     vma = find_vma(mm, untagged_addr(addr));
>>>>>
>>>>>       prctl_map.start_code    = mm->start_code;
>>>>>       prctl_map.end_code      = mm->end_code;
>>>>
>>>> Does this mean that we are left with tagged addresses for the
>>>> mm->start_code etc. values? I really don't think we should allow this,
>>>> I'm not sure what the implications are in other parts of the kernel.
>>>>
>>>> Arguably, these are not even pointer values but some address ranges. I
>>>> know we decided to relax this notion for mmap/mprotect/madvise() since
>>>> the user function prototypes take pointer as arguments but it feels like
>>>> we are overdoing it here (struct prctl_mm_map doesn't even have
>>>> pointers).
>>>>
>>>> What is the use-case for allowing tagged addresses here? Can user space
>>>> handle untagging?
>>>
>>> I don't know any use cases for this. I did it because it seems to be
>>> covered by the relaxed ABI. I'm not entirely sure what to do here,
>>> should I just drop this patch?
>>
>> If we allow tagged addresses to be passed here, we'd have to untag them
>> before they end up in the mm->start_code etc. members.
>>
>> I know we are trying to relax the ABI here w.r.t. address ranges but
>> mostly because we couldn't figure out a way to document unambiguously
>> the difference between a user pointer that may be dereferenced by the
>> kernel (tags allowed) and an address typically used for managing the
>> address space layout. Suggestions welcomed.
>>
>> I'd say just drop this patch and capture it in the ABI document.
> 
> OK, will do in v14.
> 
> Vincenzo, could you add a note about this into tour patchset?
>

Ok, I will add a note that covers this case in v3 of my document.

>>
>> --
>> Catalin

-- 
Regards,
Vincenzo

