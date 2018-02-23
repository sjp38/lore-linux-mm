Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7746B0003
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 05:27:01 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id s82so3265772qke.1
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 02:27:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x74sor1725719qkb.1.2018.02.23.02.26.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Feb 2018 02:26:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180221233825.10024-1-jhogan@kernel.org>
References: <20180221233825.10024-1-jhogan@kernel.org>
From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 23 Feb 2018 11:26:58 +0100
Message-ID: <CAK8P3a3CuNn-dSE33mhEZ9-iM7NOE3Y4AiJzpmF6ob5wrMuZpg@mail.gmail.com>
Subject: Re: [PATCH 00/13] Remove metag architecture
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <jhogan@kernel.org>
Cc: linux-metag@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Guenter Roeck <linux@roeck-us.net>, Jonathan Corbet <corbet@lwn.net>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Jason Cooper <jason@lakedaemon.net>, Marc Zyngier <marc.zyngier@arm.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Linus Walleij <linus.walleij@linaro.org>, Wim Van Sebroeck <wim@linux-watchdog.org>, Mauro Carvalho Chehab <mchehab@s-opensource.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Wolfram Sang <wsa@the-dreams.de>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-gpio@vger.kernel.org, linux-watchdog@vger.kernel.org, Linux Media Mailing List <linux-media@vger.kernel.org>, linux-i2c@vger.kernel.org

On Thu, Feb 22, 2018 at 12:38 AM, James Hogan <jhogan@kernel.org> wrote:
> These patches remove the metag architecture and tightly dependent
> drivers from the kernel. With the 4.16 kernel the ancient gcc 4.2.4
> based metag toolchain we have been using is hitting compiler bugs, so
> now seems a good time to drop it altogether.
>
> Quoting from patch 1:
>
> The earliest Meta architecture port of Linux I have a record of was an
> import of a Meta port of Linux v2.4.1 in February 2004, which was worked
> on significantly over the next few years by Graham Whaley, Will Newton,
> Matt Fleming, myself and others.
>
> Eventually the port was merged into mainline in v3.9 in March 2013, not
> long after Imagination Technologies bought MIPS Technologies and shifted
> its CPU focus over to the MIPS architecture.
>
> As a result, though the port was maintained for a while, kept on life
> support for a while longer, and useful for testing a few specific
> drivers for which I don't have ready access to the equivalent MIPS
> hardware, it is now essentially dead with no users.
>
> It is also stuck using an out-of-tree toolchain based on GCC 4.2.4 which
> is no longer maintained, now struggles to build modern kernels due to
> toolchain bugs, and doesn't itself build with a modern GCC. The latest
> buildroot port is still using an old uClibc snapshot which is no longer
> served, and the latest uClibc doesn't build with GCC 4.2.4.
>
> So lets call it a day and drop the Meta architecture port from the
> kernel. RIP Meta.

Since I brought up the architecture removal independently, I could
pick this up into a git tree that also has the removal of some of the
other architectures.

I see your tree is part of linux-next, so you could also just put it
in there and send a pull request at the merge window if you prefer.

The only real reason I see for a shared git tree would be to avoid
conflicts when we touch the same Kconfig files or #ifdefs in driver,
but Meta only appears in

config FRAME_POINTER
        bool "Compile the kernel with frame pointers"
        depends on DEBUG_KERNEL && \
                (CRIS || M68K || FRV || UML || \
                 SUPERH || BLACKFIN || MN10300 || METAG) || \
                ARCH_WANT_FRAME_POINTERS

and

include/trace/events/mmflags.h:#elif defined(CONFIG_PARISC) ||
defined(CONFIG_METAG) || defined(CONFIG_IA64)

so there is little risk.

      Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
