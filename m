Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id F19236B0007
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 05:48:36 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u200so4050778qka.21
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 02:48:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t5sor2842335qkj.122.2018.03.15.02.48.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 02:48:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2929.1521106970@warthog.procyon.org.uk>
References: <20180314143529.1456168-1-arnd@arndb.de> <2929.1521106970@warthog.procyon.org.uk>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 15 Mar 2018 10:48:35 +0100
Message-ID: <CAMuHMdXcxuzCOnFCNm4NXDv-wfYJDO5GQpB_ECu7j=2BjMhNpA@mail.gmail.com>
Subject: Re: [PATCH 00/16] remove eight obsolete architectures
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Linux-Arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, linux-block@vger.kernel.org, linux-ide@vger.kernel.org, linux-input@vger.kernel.org, netdev <netdev@vger.kernel.org>, linux-wireless <linux-wireless@vger.kernel.org>, Linux PWM List <linux-pwm@vger.kernel.org>, linux-rtc@vger.kernel.org, linux-spi <linux-spi@vger.kernel.org>, USB list <linux-usb@vger.kernel.org>, DRI Development <dri-devel@lists.freedesktop.org>, Linux Fbdev development list <linux-fbdev@vger.kernel.org>, Linux Watchdog Mailing List <linux-watchdog@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

Hi David,

On Thu, Mar 15, 2018 at 10:42 AM, David Howells <dhowells@redhat.com> wrote:
> Do we have anything left that still implements NOMMU?

Sure: arm, c6x, m68k, microblaze, and  sh.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
