Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 30D716B0003
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 00:50:30 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id r1so3979348pgq.7
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 21:50:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i1sor1738737pgq.149.2018.03.15.21.50.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 21:50:28 -0700 (PDT)
Date: Fri, 16 Mar 2018 10:20:16 +0530
From: afzal mohammed <afzal.mohd.ma@gmail.com>
Subject: Re: [PATCH 00/16] remove eight obsolete architectures
Message-ID: <20180316045016.GA7697@afzalpc>
References: <20180314143529.1456168-1-arnd@arndb.de>
 <2929.1521106970@warthog.procyon.org.uk>
 <CAK8P3a10hBz7QYk5v5MfhVMPOwFnWYTn95WZp1HtHrd7-GQpRg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAK8P3a10hBz7QYk5v5MfhVMPOwFnWYTn95WZp1HtHrd7-GQpRg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: David Howells <dhowells@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-block <linux-block@vger.kernel.org>, IDE-ML <linux-ide@vger.kernel.org>, "open list:HID CORE LAYER" <linux-input@vger.kernel.org>, Networking <netdev@vger.kernel.org>, linux-wireless <linux-wireless@vger.kernel.org>, linux-pwm@vger.kernel.org, linux-rtc@vger.kernel.org, linux-spi <linux-spi@vger.kernel.org>, linux-usb@vger.kernel.org, dri-devel <dri-devel@lists.freedesktop.org>, linux-fbdev@vger.kernel.org, linux-watchdog@vger.kernel.org, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hi,

On Thu, Mar 15, 2018 at 10:56:48AM +0100, Arnd Bergmann wrote:
> On Thu, Mar 15, 2018 at 10:42 AM, David Howells <dhowells@redhat.com> wrote:

> > Do we have anything left that still implements NOMMU?

Please don't kill !MMU.

> Yes, plenty.

> I've made an overview of the remaining architectures for my own reference[1].
> The remaining NOMMU architectures are:
> 
> - arch/arm has ARMv7-M (Cortex-M microcontroller), which is actually
> gaining traction

ARMv7-R as well, also seems ARM is coming up with more !MMU's - v8-M,
v8-R. In addition, though only of academic interest, ARM MMU capable
platform's can run !MMU Linux.

afzal

> - arch/sh has an open-source J2 core that was added not that long ago,
> it seems to
>   be the only SH compatible core that anyone is working on.
> - arch/microblaze supports both MMU/NOMMU modes (most use an MMU)
> - arch/m68k supports several NOMMU targets, both the coldfire SoCs and the
>   classic processors
> - c6x has no MMU
