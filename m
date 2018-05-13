Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B840C6B070A
	for <linux-mm@kvack.org>; Sun, 13 May 2018 06:45:10 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f3-v6so8800221plf.1
        for <linux-mm@kvack.org>; Sun, 13 May 2018 03:45:10 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id b7-v6si7655891pla.345.2018.05.13.03.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 May 2018 03:45:09 -0700 (PDT)
From: "Li, Philip" <philip.li@intel.com>
Subject: RE: [kbuild-all] /tmp/ccCNPV4P.s:35: Error: .err encountered
Date: Sun, 13 May 2018 10:45:05 +0000
Message-ID: <831EE4E5E37DCC428EB295A351E662494CB14775@shsmsx102.ccr.corp.intel.com>
References: <201805122003.IkOs6MjS%fengguang.wu@intel.com>
 <CACT4Y+ZZp_QbtFxBfP5dtdx4yfb5FZOWm54fDg=qQQ7u0J=HzQ@mail.gmail.com>
In-Reply-To: <CACT4Y+ZZp_QbtFxBfP5dtdx4yfb5FZOWm54fDg=qQQ7u0J=HzQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, lkp <lkp@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "kbuild-all@01.org" <kbuild-all@01.org>, Johannes Weiner <hannes@cmpxchg.org>

> Subject: Re: [kbuild-all] /tmp/ccCNPV4P.s:35: Error: .err encountered
>=20
> On Sat, May 12, 2018 at 2:26 PM, kbuild test robot <lkp@intel.com> wrote:
> > bisected to: 05cedaec9b243511f8db62bcd4b1c35c374eba24  arm: port KCOV t=
o
> arm
> > commit date: 12 hours ago
> > config: arm-allmodconfig (attached as .config)
> > compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-
> tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout 05cedaec9b243511f8db62bcd4b1c35c374eba24
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=3Darm
> >
> > All errors (new ones prefixed by >>):
> >
> >    /tmp/ccCNPV4P.s: Assembler messages:
> >>> /tmp/ccCNPV4P.s:35: Error: .err encountered
> >    /tmp/ccCNPV4P.s:36: Error: .err encountered
> >    /tmp/ccCNPV4P.s:37: Error: .err encountered
>=20
>=20
> Hi,
>=20
> What git tree contains this commit? I fetched all of:
sorry, that we have regression in code which is solved, but it may mess up =
some data
and leads to missing info like no exact tree mentioned here. We will contin=
ue fixing things up.

For the commit itself, the bot caught it from git://git.cmpxchg.org/linux-m=
motm.git, which
is one you mentioned below. Is it possible the commit is rebased?

commit 05cedaec9b243511f8db62bcd4b1c35c374eba24
Author: Dmitry Vyukov <dvyukov@google.com>
Date:   Sat May 12 00:06:09 2018 +0000

    arm: port KCOV to arm

    KCOV is code coverage collection facility used, in particular, by
    syzkaller system call fuzzer.  There is some interest in using syzkalle=
r
    on arm devices.  So port KCOV to arm.

>=20
> git://git.cmpxchg.org/linux-mmots.git master
> git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git master
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next-history.git
>=20
> but I still don't have 05cedaec9b243511f8db62bcd4b1c35c374eba24.
>=20
> I tried these instructions on the tree which I used to develop the
> patch (on top of git://git.cmpxchg.org/linux-mmots.git), but I got:
>=20
> make[2]: *** No rule to make target 'drivers/spi/spi-bcm53xx.c',
> needed by 'drivers/spi/spi-bcm53xx.o'.  Stop.
> _______________________________________________
> kbuild-all mailing list
> kbuild-all@lists.01.org
> https://lists.01.org/mailman/listinfo/kbuild-all
