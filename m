Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF1D6B06F1
	for <linux-mm@kvack.org>; Sun, 13 May 2018 07:59:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j14-v6so8270593pfn.11
        for <linux-mm@kvack.org>; Sun, 13 May 2018 04:59:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p1-v6sor3841109plb.149.2018.05.13.04.59.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 13 May 2018 04:59:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <831EE4E5E37DCC428EB295A351E662494CB14775@shsmsx102.ccr.corp.intel.com>
References: <201805122003.IkOs6MjS%fengguang.wu@intel.com> <CACT4Y+ZZp_QbtFxBfP5dtdx4yfb5FZOWm54fDg=qQQ7u0J=HzQ@mail.gmail.com>
 <831EE4E5E37DCC428EB295A351E662494CB14775@shsmsx102.ccr.corp.intel.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 13 May 2018 13:59:16 +0200
Message-ID: <CACT4Y+aD3LTs-oCFU1-x=beL8+Arw=QTo_wa064WhEeGguTcQg@mail.gmail.com>
Subject: Re: [kbuild-all] /tmp/ccCNPV4P.s:35: Error: .err encountered
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Philip" <philip.li@intel.com>
Cc: lkp <lkp@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "kbuild-all@01.org" <kbuild-all@01.org>, Johannes Weiner <hannes@cmpxchg.org>

On Sun, May 13, 2018 at 12:45 PM, Li, Philip <philip.li@intel.com> wrote:
>> Subject: Re: [kbuild-all] /tmp/ccCNPV4P.s:35: Error: .err encountered
>>
>> On Sat, May 12, 2018 at 2:26 PM, kbuild test robot <lkp@intel.com> wrote:
>> > bisected to: 05cedaec9b243511f8db62bcd4b1c35c374eba24  arm: port KCOV to
>> arm
>> > commit date: 12 hours ago
>> > config: arm-allmodconfig (attached as .config)
>> > compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
>> > reproduce:
>> >         wget https://raw.githubusercontent.com/intel/lkp-
>> tests/master/sbin/make.cross -O ~/bin/make.cross
>> >         chmod +x ~/bin/make.cross
>> >         git checkout 05cedaec9b243511f8db62bcd4b1c35c374eba24
>> >         # save the attached .config to linux build tree
>> >         make.cross ARCH=arm
>> >
>> > All errors (new ones prefixed by >>):
>> >
>> >    /tmp/ccCNPV4P.s: Assembler messages:
>> >>> /tmp/ccCNPV4P.s:35: Error: .err encountered
>> >    /tmp/ccCNPV4P.s:36: Error: .err encountered
>> >    /tmp/ccCNPV4P.s:37: Error: .err encountered
>>
>>
>> Hi,
>>
>> What git tree contains this commit? I fetched all of:
> sorry, that we have regression in code which is solved, but it may mess up some data
> and leads to missing info like no exact tree mentioned here. We will continue fixing things up.
>
> For the commit itself, the bot caught it from git://git.cmpxchg.org/linux-mmotm.git, which
> is one you mentioned below. Is it possible the commit is rebased?
>
> commit 05cedaec9b243511f8db62bcd4b1c35c374eba24
> Author: Dmitry Vyukov <dvyukov@google.com>
> Date:   Sat May 12 00:06:09 2018 +0000
>
>     arm: port KCOV to arm
>
>     KCOV is code coverage collection facility used, in particular, by
>     syzkaller system call fuzzer.  There is some interest in using syzkaller
>     on arm devices.  So port KCOV to arm.

Now see it. That's a different tree (mmotm vs mmots).

But I can't reproduce the failure:

$ git status
HEAD detached at 05cedaec9b24

$ make.cross ARCH=arm -j64
make CROSS_COMPILE=/opt/gcc-4.9.0-nolibc/arm-unknown-linux-gnueabi/bin/arm-unknown-linux-gnueabi-
ARCH=arm -j64
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CHK     scripts/mod/devicetable-offsets.h
  CHK     include/generated/timeconst.h
  CHK     include/generated/bounds.h
  CHK     include/generated/asm-offsets.h
  CALL    scripts/checksyscalls.sh
  CHK     include/generated/compile.h
  CHK     include/generated/at91_pm_data-offsets.h
  CHK     include/generated/ti-pm-asm-offsets.h
  CHK     include/generated/ti-emif-asm-offsets.h
  CHK     kernel/config_data.h
  CHK     include/generated/uapi/linux/version.h
  Kernel: arch/arm/boot/Image is ready
  Building modules, stage 2.
  Kernel: arch/arm/boot/zImage is ready
  MODPOST 6609 modules
