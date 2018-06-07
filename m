Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1FD6B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 01:41:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y21-v6so4088325pfm.4
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 22:41:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u11-v6sor11254888plr.12.2018.06.06.22.41.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Jun 2018 22:41:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1528336942.3147.52.camel@intel.com>
References: <201805210314.e6bdStHL%fengguang.wu@intel.com> <CACT4Y+bR+ywj_OtGDYiCp+PZ4MfdqfrXg5XQwN36uRnNCEHEZg@mail.gmail.com>
 <831EE4E5E37DCC428EB295A351E662494CB5166D@shsmsx102.ccr.corp.intel.com>
 <831EE4E5E37DCC428EB295A351E662494CB9C137@shsmsx102.ccr.corp.intel.com> <1528336942.3147.52.camel@intel.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 7 Jun 2018 07:41:29 +0200
Message-ID: <CACT4Y+YgHaji6k-yxseGOqG4EQ0F4Oq1GOw5fPpRJccpaP2FhQ@mail.gmail.com>
Subject: Re: FW: [kbuild-all] [linux-next:master 5885/8111]
 /tmp/cc3gKKeM.s:35: Error: .err encountered
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Rong <rongx.a.chen@intel.com>
Cc: kbuild test robot <lkp@intel.com>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org, Arnd Bergmann <arnd@arndb.de>

On Thu, Jun 7, 2018 at 4:02 AM, Chen Rong <rongx.a.chen@intel.com> wrote:
> Hi Dmitry,
>
> We have updated the make.cross. you could get the new one from https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross
> and run the command "GCC_VERSION=7.2.0 make.cross ARCH=arm"

Do you mean that the script now reproduces this error?

But I think that Arnd has fixed this with "ARM: disable KCOV for
trusted foundations code" now:
https://patchwork.kernel.org/patch/10434909/
The failure mode he referenced matches reported here.


>> -----Original Message-----
>> From: kbuild-all [mailto:kbuild-all-bounces@lists.01.org] On Behalf Of Li, Philip
>> Sent: Saturday, May 26, 2018 10:37 PM
>> To: Dmitry Vyukov <dvyukov@google.com>; lkp <lkp@intel.com>
>> Cc: Linux Memory Management List <linux-mm@kvack.org>; Andrew Morton <akpm@linux-foundation.org>; kbuild-all@01.org
>> Subject: Re: [kbuild-all] [linux-next:master 5885/8111] /tmp/cc3gKKeM.s:35: Error: .err encountered
>>
>> > Subject: Re: [kbuild-all] [linux-next:master 5885/8111] /tmp/cc3gKKeM.s:35:
>> > Error: .err encountered
>> >
>> > On Sun, May 20, 2018 at 9:15 PM, kbuild test robot <lkp@intel.com> wrote:
>> > > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
>> > > head:   fbbe3b8c2c9c5f84caf668703c26154cb4fbb9d1
>> > > commit: 3b67022379d3d0c6a5cc5152f6b46eeea635a194 [5885/8111] arm: port
>> >
>> > KCOV to arm
>> > > config: arm-allmodconfig (attached as .config)
>> > > compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
>> > > reproduce:
>> > >         wget https://raw.githubusercontent.com/intel/lkp-
>> >
>> > tests/master/sbin/make.cross -O ~/bin/make.cross
>> > >         chmod +x ~/bin/make.cross
>> > >         git checkout 3b67022379d3d0c6a5cc5152f6b46eeea635a194
>> > >         # save the attached .config to linux build tree
>> > >         make.cross ARCH=arm
>> > >
>> > > All errors (new ones prefixed by >>):
>> > >
>> > >    /tmp/cc3gKKeM.s: Assembler messages:
>> > > > > /tmp/cc3gKKeM.s:35: Error: .err encountered
>> > >
>> > >    /tmp/cc3gKKeM.s:36: Error: .err encountered
>> > >    /tmp/cc3gKKeM.s:37: Error: .err encountered
>> >
>> > I've tried to reproduce this following the instructions, but I failed,
>>
>> thanks for input, we will follow up this to see whether there's issue
>> in bot side.
>>
>> > build succeeds for me:
>> > https://www.spinics.net/lists/linux-mm/msg152336.html
>> > _______________________________________________
>> > kbuild-all mailing list
>> > kbuild-all@lists.01.org
>> > https://lists.01.org/mailman/listinfo/kbuild-all
>>
>> _______________________________________________
>> kbuild-all mailing list
>> kbuild-all@lists.01.org
>> https://lists.01.org/mailman/listinfo/kbuild-all
