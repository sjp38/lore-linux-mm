Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A562B6B06FF
	for <linux-mm@kvack.org>; Sun, 13 May 2018 04:53:14 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k189-v6so5060152pgc.10
        for <linux-mm@kvack.org>; Sun, 13 May 2018 01:53:14 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c4-v6sor3426580plo.93.2018.05.13.01.53.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 13 May 2018 01:53:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201805122003.IkOs6MjS%fengguang.wu@intel.com>
References: <201805122003.IkOs6MjS%fengguang.wu@intel.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 13 May 2018 10:52:52 +0200
Message-ID: <CACT4Y+ZZp_QbtFxBfP5dtdx4yfb5FZOWm54fDg=qQQ7u0J=HzQ@mail.gmail.com>
Subject: Re: /tmp/ccCNPV4P.s:35: Error: .err encountered
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, May 12, 2018 at 2:26 PM, kbuild test robot <lkp@intel.com> wrote:
> bisected to: 05cedaec9b243511f8db62bcd4b1c35c374eba24  arm: port KCOV to arm
> commit date: 12 hours ago
> config: arm-allmodconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 05cedaec9b243511f8db62bcd4b1c35c374eba24
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm
>
> All errors (new ones prefixed by >>):
>
>    /tmp/ccCNPV4P.s: Assembler messages:
>>> /tmp/ccCNPV4P.s:35: Error: .err encountered
>    /tmp/ccCNPV4P.s:36: Error: .err encountered
>    /tmp/ccCNPV4P.s:37: Error: .err encountered


Hi,

What git tree contains this commit? I fetched all of:

git://git.cmpxchg.org/linux-mmots.git master
git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git master
git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next-history.git

but I still don't have 05cedaec9b243511f8db62bcd4b1c35c374eba24.

I tried these instructions on the tree which I used to develop the
patch (on top of git://git.cmpxchg.org/linux-mmots.git), but I got:

make[2]: *** No rule to make target 'drivers/spi/spi-bcm53xx.c',
needed by 'drivers/spi/spi-bcm53xx.o'.  Stop.
