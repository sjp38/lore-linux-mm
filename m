Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62B46828E1
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 16:41:42 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ao6so105854580pac.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 13:41:42 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id 2si1732320pfu.115.2016.06.22.13.41.41
        for <linux-mm@kvack.org>;
        Wed, 22 Jun 2016 13:41:41 -0700 (PDT)
Subject: Re: JITs and 52-bit VA
References: <4A8E6E6D-6CF7-4964-A62E-467AE287D415@linaro.org>
 <576AA67E.50009@codeaurora.org>
 <CALCETrWQi1n4nbk1BdEnvXy1u3-4fX7kgWn6OerqOxHM6OCgXA@mail.gmail.com>
 <20160622191843.GA2045@uranus.lan>
 <CALCETrUH0uxfASkHkVVJhuFkEXvuVXhLc-Ed=Utn9E5vzx=Vzg@mail.gmail.com>
 <576AED88.6040805@intel.com> <20160622201754.GD2045@uranus.lan>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <576AF804.3090901@intel.com>
Date: Wed, 22 Jun 2016 13:41:40 -0700
MIME-Version: 1.0
In-Reply-To: <20160622201754.GD2045@uranus.lan>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Christopher Covington <cov@codeaurora.org>, Maxim Kuvyrkov <maxim.kuvyrkov@linaro.org>, Linaro Dev Mailman List <linaro-dev@lists.linaro.org>, Arnd Bergmann <arnd.bergmann@linaro.org>, Mark Brown <broonie@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <dsafonov@virtuozzo.com>

On 06/22/2016 01:17 PM, Cyrill Gorcunov wrote:
> On Wed, Jun 22, 2016 at 12:56:56PM -0700, Dave Hansen wrote:
>>
>> Yeah, cgroups don't make a lot of sense.
>>
>> On x86, the 48-bit virtual address is even hard-coded in the ABI[1].  So
>> we can't change *any* program's layout without either breaking the ABI
>> or having it opt in.
>>
>> But, we're also lucky to only have one VA layout since day one.
>>
>> 1. www.x86-64.org/documentation/abi.pdf - a??... Therefore, conforming
>> processes may only use addresses from 0x00000000 00000000 to 0x00007fff
>> ffffffff .a??
> 
> Yes, but noone forces you to write conforming programs ;)
> After all while hw allows you to run VA with bits > than
> 48 it's fine, all side effects of breaking abi is up to
> program author (iirc on x86 there is up to 52 bits on
> hw level allowed, don't have specs under my hands?)

My point was that you can't restrict the vaddr space without breaking
the ABI because apps expect to be able to use 0x00007fffffffffff.  You
also can't extend the vaddr space because apps can *also* expect that
there are no valid vaddrs past 0x00007fffffffffff.

So, whatever happens here, at least on x86, we can't do anything to the
vaddr space without it being an opt-in for *each* *app*.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
