Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1EB6B0003
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 07:26:11 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id n25so6546157qtl.13
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 04:26:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k128sor1683655qke.106.2018.02.23.04.26.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Feb 2018 04:26:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180223110207.GA14446@saruman>
References: <20180221233825.10024-1-jhogan@kernel.org> <CAK8P3a3CuNn-dSE33mhEZ9-iM7NOE3Y4AiJzpmF6ob5wrMuZpg@mail.gmail.com>
 <20180223110207.GA14446@saruman>
From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 23 Feb 2018 13:26:09 +0100
Message-ID: <CAK8P3a12RKQvcmnPRHcDkDKq+uMWP79SuRdDz3_vi9YRM==GVw@mail.gmail.com>
Subject: Re: [PATCH 00/13] Remove metag architecture
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <jhogan@kernel.org>
Cc: "open list:METAG ARCHITECTURE" <linux-metag@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Guenter Roeck <linux@roeck-us.net>, Jonathan Corbet <corbet@lwn.net>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Jason Cooper <jason@lakedaemon.net>, Marc Zyngier <marc.zyngier@arm.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Linus Walleij <linus.walleij@linaro.org>, Wim Van Sebroeck <wim@linux-watchdog.org>, Mauro Carvalho Chehab <mchehab@s-opensource.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Wolfram Sang <wsa@the-dreams.de>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-gpio@vger.kernel.org, linux-watchdog@vger.kernel.org, Linux Media Mailing List <linux-media@vger.kernel.org>, linux-i2c@vger.kernel.org

On Fri, Feb 23, 2018 at 12:02 PM, James Hogan <jhogan@kernel.org> wrote:
> On Fri, Feb 23, 2018 at 11:26:58AM +0100, Arnd Bergmann wrote:
>> On Thu, Feb 22, 2018 at 12:38 AM, James Hogan <jhogan@kernel.org> wrote:
>> > So lets call it a day and drop the Meta architecture port from the
>> > kernel. RIP Meta.
>>
>> Since I brought up the architecture removal independently, I could
>> pick this up into a git tree that also has the removal of some of the
>> other architectures.
>>
>> I see your tree is part of linux-next, so you could also just put it
>> in there and send a pull request at the merge window if you prefer.
>>
>> The only real reason I see for a shared git tree would be to avoid
>> conflicts when we touch the same Kconfig files or #ifdefs in driver,
>> but Meta only appears in
>>
>> config FRAME_POINTER
>>         bool "Compile the kernel with frame pointers"
>>         depends on DEBUG_KERNEL && \
>>                 (CRIS || M68K || FRV || UML || \
>>                  SUPERH || BLACKFIN || MN10300 || METAG) || \
>>                 ARCH_WANT_FRAME_POINTERS
>>
>> and
>>
>> include/trace/events/mmflags.h:#elif defined(CONFIG_PARISC) ||
>> defined(CONFIG_METAG) || defined(CONFIG_IA64)
>>
>> so there is little risk.
>
> I'm happy to put v2 in linux-next now (only patch 4 has changed, I just
> sent an updated version), and send you a pull request early next week so
> you can take it from there. The patches can't be directly applied with
> git-am anyway thanks to the -D option to make them more concise.
>
> Sound okay?

Yes, sounds good, thanks!

       Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
