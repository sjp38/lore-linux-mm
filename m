Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22BECC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:00:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7D132084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 09:00:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7D132084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 589AD6B0003; Thu, 20 Jun 2019 05:00:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 512308E0002; Thu, 20 Jun 2019 05:00:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DA428E0001; Thu, 20 Jun 2019 05:00:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E302B6B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 05:00:07 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n49so3327255edd.15
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 02:00:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2cv6mjZn+837cj1cUtBJI/JvDmliAPGUL6FTcqFT6V4=;
        b=fKBjo9uJb7iKLasVLbPd9sjm+oGA7f4rHDr6n6zQvozWt002XhLJ1sqULNGHt5YvIG
         7cnYfW7TrqM34UUHxHij+6n7I/uVDgOLPPmt5yYsABSWbPDKIBPe/ZmK36PPMrQeT74r
         INcPmYsaa6AaTOFiVehIDbbdUK0X5TZKURYE200MxfLnLVS3Ig22RtasLFF1mhkxhyJI
         La5M1ytGUo7LCoRckHcwcgyxSdsnYtn0emrDQCbboeJ7/gpa7li16Yyrfyan+s3/K6ZS
         DTimddU4WgOsi9Wbnq6fJ6NC5ykW6sVyZABsK6EVlPreZnZIRRdYeZuThVgCQP/CzaUa
         rjRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXf7ZixIV+G+FjYVM8kgERL0F/E4Rb1gDCyp+auSzDgk3QGwQlz
	8CatZFz84kcFetyNhKFWP37hlBapP+u0iRJFviSVLYo34Qs2K+wS7/Uh7tEHbgtzAF+hwR9FzXW
	8UqlFrQOQu2Xta1uuSitYktA46gjI4Pdf8bZQFlgU+p9y5j7BS50NRRkuINW4QqMBLQ==
X-Received: by 2002:a50:97c8:: with SMTP id f8mr90520231edb.176.1561021207475;
        Thu, 20 Jun 2019 02:00:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQ9OoflMnC6Yw1jBsS6f7cu1mMrdbhZlB9PotdFJwIAKyV4AHlP5wXziaYVlbUk3HApLCH
X-Received: by 2002:a50:97c8:: with SMTP id f8mr90520112edb.176.1561021206563;
        Thu, 20 Jun 2019 02:00:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561021206; cv=none;
        d=google.com; s=arc-20160816;
        b=Scj9cFeJLaqZ2AyeT5j+gIz8aJ0imM7njKeYks+odkJ6BRH73pUxe+TNB9LAB/R1H9
         TRvFz0BwZWhLOWyv253KRQ+BgxhDx8LWAhlKJFhCnDIR9F08+3pdGhHJRuJcYO5n5uIO
         GlgoPmgMOkdQ0STDuRjSSCfGlacUIZoguVA8c8Fqm9NfEpFHfPm8VdGayG5kRoEx0U6O
         404utJS2CPVTzyAzlfKAKgDhDzgRbjIR6WOJSQcrbRzxlsOWr6dAOUaUbZyL+CTm7GSi
         3WfvQea95RSc/a+T4njstaqMxvmvOyvvVCZpHcmPZUvM6ouTKykzp9VJqut4F2RhCcsx
         oGMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=2cv6mjZn+837cj1cUtBJI/JvDmliAPGUL6FTcqFT6V4=;
        b=jcF8l861dryP+5Z8rEb0vkX0aejyspEF3p6XSL18PGQ0lmzS+8uGS6EGzS941Z+guG
         +uwTBk+TviQNhrTPrH4ecXHx9MR3MUBwOENL90NnYQXrOzxDS2j4Q7eFFPVCsBYl0zI4
         DA8PEOJTF8tvum0v15FDAfzoMxa1R3EzDK8syc4uS+9OiBc/fUC0fqMMlrybtS2eXpXA
         elxVVOX84BFtwWkaoeGRxnPmlo63i34mPLL8zRa3mZ7RUXt++qvU+vahRfOMtbQaJx7F
         X8iatl1SHfxFrSBBSlpSRHixHtP+uPn/spNY/LNb0tQIKoY1SdFnLJwPu0UMf4xNAtE/
         Uk4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g15si9614253ejh.113.2019.06.20.02.00.05
        for <linux-mm@kvack.org>;
        Thu, 20 Jun 2019 02:00:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0D037344;
	Thu, 20 Jun 2019 02:00:05 -0700 (PDT)
Received: from [10.162.42.129] (p8cg001049571a15.blr.arm.com [10.162.42.129])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 99FF43F246;
	Thu, 20 Jun 2019 02:00:03 -0700 (PDT)
Subject: Re: [linux-next:master 6470/6646] include/linux/kprobes.h:477:9:
 error: implicit declaration of function 'kprobe_fault_handler'; did you mean
 'kprobe_page_fault'?
To: Andrew Morton <akpm@linux-foundation.org>,
 kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Linux Memory Management List <linux-mm@kvack.org>
References: <201906151005.MbWIPMeb%lkp@intel.com>
 <20190617190734.e044c1ba48d69a3cb3e01f59@linux-foundation.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <702ba0e8-0ef5-c5df-a350-b928ac984d58@arm.com>
Date: Thu, 20 Jun 2019 14:30:25 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190617190734.e044c1ba48d69a3cb3e01f59@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Andrew,

On 06/18/2019 07:37 AM, Andrew Morton wrote:
> On Sat, 15 Jun 2019 10:55:07 +0800 kbuild test robot <lkp@intel.com> wrote:
> 
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
>> head:   f4788d37bc84e27ac9370be252afb451bf6ef718
>> commit: 4dd635bce90e8b6ed31c08cd654deca29f4d9d66 [6470/6646] mm, kprobes: generalize and rename notify_page_fault() as kprobe_page_fault()
>> config: mips-allmodconfig (attached as .config)
>> compiler: mips-linux-gcc (GCC) 7.4.0
>> reproduce:
>>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>>         chmod +x ~/bin/make.cross
>>         git checkout 4dd635bce90e8b6ed31c08cd654deca29f4d9d66
>>         # save the attached .config to linux build tree
>>         GCC_VERSION=7.4.0 make.cross ARCH=mips 
>>
>> If you fix the issue, kindly add following tag
>> Reported-by: kbuild test robot <lkp@intel.com>
>>
>> All errors (new ones prefixed by >>):
>>
>>    In file included from net//sctp/offload.c:11:0:
>>    include/linux/kprobes.h: In function 'kprobe_page_fault':
>>>> include/linux/kprobes.h:477:9: error: implicit declaration of function 'kprobe_fault_handler'; did you mean 'kprobe_page_fault'? [-Werror=implicit-function-declaration]
>>      return kprobe_fault_handler(regs, trap);
> 
> Urgh, OK, thanks.
> 
> kprobe_fault_handler() is only ever defined and referenced in arch code
> and generic code has no right to be assuming that the architecture
> actually provides it.  And so it is with mips (at least).

Hmm, so the problem really is that on mips arch even though CONFIG_KPROBES
is enabled, it does not export (though it defines) a kprobe_fault_handler()
implementation unlike all other architectures.

Now that generic code calls kprobe_fault_handler(), should not all arch be
providing one when they subscribe to CONFIG_KPROBES ? In which case mips
should just export it's existing definition to fix this build problem.

> 
> The !CONFIG_KPROBES stub version of kprobe_fault_handler() should not
> have been placed in include/linux/kprobes.h!  Each arch should have
> defined its own, if that proved necessary.

I guess its there in include/linux/kprobes.h! because !CONFIG_KPROBES stub
version for all archs will exactly look the same.

> 
> Oh well, ho hum.  Hopefully Anshuman will be able to come up with a fix
> for mips and any similarly-affected architectures.

Will export it's existing definition via arch/mips/include/asm/kprobes.h
unless that is problematic for other reasons. Another solution would be
to define an weak symbol in include/linux/kprobes.h for CONFIG_KPROBES.
But that will not be correct because kprobe_fault_handler() by all means
is always platform specific.

> 
> Also, please very carefully check that this patchset is correct for all
> architectures!  kprobe_fault_handler() could conceivably do different
> things on different architectures.

Agreed.

