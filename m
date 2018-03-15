Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D16A86B0005
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 06:42:27 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o22-v6so5459595itc.9
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 03:42:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r66sor2197355ioe.43.2018.03.15.03.42.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 03:42:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <6c9d075c-d7a8-72a5-9b2d-af1feaa06c6c@suse.de>
References: <20180314143529.1456168-1-arnd@arndb.de> <2929.1521106970@warthog.procyon.org.uk>
 <6c9d075c-d7a8-72a5-9b2d-af1feaa06c6c@suse.de>
From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 15 Mar 2018 11:42:25 +0100
Message-ID: <CAK8P3a01pfvsdM1mR8raU9dA7p4H-jRJz2Y8-+KEY76W_Mukpg@mail.gmail.com>
Subject: Re: [PATCH 00/16] remove eight obsolete architectures
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hannes Reinecke <hare@suse.de>
Cc: David Howells <dhowells@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-block <linux-block@vger.kernel.org>, IDE-ML <linux-ide@vger.kernel.org>, "open list:HID CORE LAYER" <linux-input@vger.kernel.org>, Networking <netdev@vger.kernel.org>, linux-wireless <linux-wireless@vger.kernel.org>, linux-pwm@vger.kernel.org, linux-rtc@vger.kernel.org, linux-spi <linux-spi@vger.kernel.org>, linux-usb@vger.kernel.org, dri-devel <dri-devel@lists.freedesktop.org>, linux-fbdev@vger.kernel.org, linux-watchdog@vger.kernel.org, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Mar 15, 2018 at 10:59 AM, Hannes Reinecke <hare@suse.de> wrote:
> On 03/15/2018 10:42 AM, David Howells wrote:
>> Do we have anything left that still implements NOMMU?
>>
> RISC-V ?
> (evil grin :-)

Is anyone producing a chip that includes enough of the Privileged ISA spec
to have things like system calls, but not the MMU parts?

I thought at least initially the kernel only supports hardware that has a rather
complete feature set.

       Arnd
