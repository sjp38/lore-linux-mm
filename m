Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 946ED440441
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 16:48:39 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id d63so143141766ioj.2
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 13:48:39 -0800 (PST)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id c18si708430igr.94.2016.02.05.13.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 13:48:38 -0800 (PST)
Received: by mail-ig0-x22e.google.com with SMTP id ik10so50389834igb.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 13:48:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160104220743.GP19062@n2100.arm.linux.org.uk>
References: <20151202202725.GA794@www.outflux.net>
	<20151223195129.GP2793@atomide.com>
	<567B04AB.6010906@redhat.com>
	<20151223212911.GR2793@atomide.com>
	<alpine.LFD.2.20.1512231637110.3603@knanqh.ubzr>
	<20151224001121.GS2793@atomide.com>
	<20151224003406.GA8644@n2100.arm.linux.org.uk>
	<CAGXu5j+MrX-OvnVTYH0hqF2XgZW10PQOviyN=e5heejLsXewVA@mail.gmail.com>
	<20160104220743.GP19062@n2100.arm.linux.org.uk>
Date: Fri, 5 Feb 2016 13:48:38 -0800
Message-ID: <CAGXu5jJTOZL5yQfj5KuRjVO00mnNL3yd=7ONacYK96yLAOtgKg@mail.gmail.com>
Subject: Re: [PATCH v2] ARM: mm: flip priority of CONFIG_DEBUG_RODATA
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Tony Lindgren <tony@atomide.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Laura Abbott <labbott@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Laura Abbott <labbott@fedoraproject.org>

On Mon, Jan 4, 2016 at 2:07 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Mon, Jan 04, 2016 at 12:34:28PM -0800, Kees Cook wrote:
>> On Wed, Dec 23, 2015 at 4:34 PM, Russell King - ARM Linux
>> <linux@arm.linux.org.uk> wrote:
>> > On Wed, Dec 23, 2015 at 04:11:22PM -0800, Tony Lindgren wrote:
>> >> * Nicolas Pitre <nicolas.pitre@linaro.org> [151223 13:45]:
>> >> > We fixed a bunch of similar issues where code was located in the .data
>> >> > section for ease of use from assembly code.  See commit b4e61537 and
>> >> > d0776aff for example.
>> >>
>> >> Thanks hey some assembly fun for the holidays :) I also need to check what
>> >> all gets relocated to SRAM here.
>> >>
>> >> In any case, seems like the $subject patch is too intrusive for v4.5 at
>> >> this point.
>> >
>> > Given Christmas and an unknown time between that and the merge window
>> > actually opening, I decided Tuesday would be the last day I take any
>> > patches into my tree - and today would be the day that I drop anything
>> > that causes problems.
>> >
>> > So, I've already dropped this, so tomorrow's linux-next should not have
>> > this change.
>> >
>> > You'll still see breakage if people enable RODATA though, but that's no
>> > different from previous kernels.
>>
>> Ugh, sorry for the breakage.
>>
>> Should this patch stay as-is and people will fix their various RODATA
>> failures during the next devel window, or should I remove the "default
>> y if CPU_V7"?
>
> I think we'll keep it as-is, and have another go with it at -rc1 time,
> when people have ample chance to then queue up fixes.
>
> They'll have had notice of it, so there's no excuse folk can't work on
> the problem in the mean time.  (But, of course, they won't...)

Hi,

Just checking on this -- I resent it to the patch tracker at -rc1
time. Is this waiting for the other fixes to land first, or is there
something I should be doing?

Thanks!

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
