Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D77056B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 16:24:24 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id j23so2692354qtn.23
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 13:24:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q2sor5325144qti.141.2018.03.07.13.24.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Mar 2018 13:24:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180221233825.10024-1-jhogan@kernel.org>
References: <20180221233825.10024-1-jhogan@kernel.org>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 7 Mar 2018 22:24:23 +0100
Message-ID: <CAK8P3a2qV5n57f7=FC0nYZWfeXCVaOaK4R_7Wr74p3ZMyuwJNQ@mail.gmail.com>
Subject: Re: [PATCH 00/13] Remove metag architecture
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <jhogan@kernel.org>
Cc: "open list:METAG ARCHITECTURE" <linux-metag@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Guenter Roeck <linux@roeck-us.net>, Jonathan Corbet <corbet@lwn.net>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Jason Cooper <jason@lakedaemon.net>, Marc Zyngier <marc.zyngier@arm.com>, Daniel Lezcano <daniel.lezcano@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, Linus Walleij <linus.walleij@linaro.org>, Wim Van Sebroeck <wim@linux-watchdog.org>, Mauro Carvalho Chehab <mchehab@s-opensource.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Wolfram Sang <wsa@the-dreams.de>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-gpio@vger.kernel.org, linux-watchdog@vger.kernel.org, Linux Media Mailing List <linux-media@vger.kernel.org>, linux-i2c@vger.kernel.org

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

I've pulled it into my asm-generic tree now, which is also part of linux-next,
and followed up with patches removing frv, m32r, score, unicore32
and blackfin. I have not removed the device drivers yet, but I'm working
on that.

       Arnd
