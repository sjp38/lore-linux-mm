Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 936106B0005
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:11:50 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b2-v6so1496694plz.17
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 10:11:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q1sor553593pgt.65.2018.03.20.10.11.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 10:11:49 -0700 (PDT)
Date: Tue, 20 Mar 2018 10:11:47 -0700 (PDT)
Subject: Re: [PATCH 00/16] remove eight obsolete architectures
In-Reply-To: <CAK8P3a01pfvsdM1mR8raU9dA7p4H-jRJz2Y8-+KEY76W_Mukpg@mail.gmail.com>
From: Palmer Dabbelt <palmer@sifive.com>
Message-ID: <mhng-f6731cb9-8394-419d-b14b-c6fcd6c0930d@palmer-si-x1c4>
Mime-Version: 1.0 (MHng)
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: hare@suse.de, dhowells@redhat.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-block@vger.kernel.org, linux-ide@vger.kernel.org, linux-input@vger.kernel.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-pwm@vger.kernel.org, linux-rtc@vger.kernel.org, linux-spi@vger.kernel.org, linux-usb@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-fbdev@vger.kernel.org, linux-watchdog@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, 15 Mar 2018 03:42:25 PDT (-0700), Arnd Bergmann wrote:
> On Thu, Mar 15, 2018 at 10:59 AM, Hannes Reinecke <hare@suse.de> wrote:
>> On 03/15/2018 10:42 AM, David Howells wrote:
>>> Do we have anything left that still implements NOMMU?
>>>
>> RISC-V ?
>> (evil grin :-)
>
> Is anyone producing a chip that includes enough of the Privileged ISA spec
> to have things like system calls, but not the MMU parts?
>
> I thought at least initially the kernel only supports hardware that has a rather
> complete feature set.

We currently do not have a NOMMU port.  As far as I know, everyone who's
currently producing RISC-V hardware with enough memory to run Linux has S mode
with paging support.  The ISA allows for S mode without paging but there's no
hardware for that -- if you're going to put a DRAM controller on there then
paging seems pretty cheap.  You could run a NOMMU port on a system with S-mode
and paging, but With all the superpage stuff I don't think you'll get an
appreciable performance win for any workload running without an MMU so there's
nothing to justify the work (and incompatibility) of a NOMMU port there.

While I think you could implement a NOMMU port on a machine with only M and U
modes (and therefor no address translation at all), I don't know of any MU-only
machines that have enough memory to run Linux (ours have less than 32KiB).  A
SBI-free Linux would be a prerequisite for this, but there's some interest in
that outside of a NOMMU port so it might materialize anyway.

Of course, QEMU could probably be tricked into emulating one of these machines
with little to no effort :)...  That said, I doubt we'll see a NOMMU port
materialize without some real hardware as it's a lot of work for a QEMU-only
target.
