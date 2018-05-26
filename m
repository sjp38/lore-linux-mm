Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58A506B0003
	for <linux-mm@kvack.org>; Sat, 26 May 2018 10:37:30 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id g6-v6so4807906plq.9
        for <linux-mm@kvack.org>; Sat, 26 May 2018 07:37:30 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h12-v6si28300506plt.494.2018.05.26.07.37.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 May 2018 07:37:27 -0700 (PDT)
From: "Li, Philip" <philip.li@intel.com>
Subject: RE: [kbuild-all] [linux-next:master 5885/8111] /tmp/cc3gKKeM.s:35:
 Error: .err encountered
Date: Sat, 26 May 2018 14:37:23 +0000
Message-ID: <831EE4E5E37DCC428EB295A351E662494CB5166D@shsmsx102.ccr.corp.intel.com>
References: <201805210314.e6bdStHL%fengguang.wu@intel.com>
 <CACT4Y+bR+ywj_OtGDYiCp+PZ4MfdqfrXg5XQwN36uRnNCEHEZg@mail.gmail.com>
In-Reply-To: <CACT4Y+bR+ywj_OtGDYiCp+PZ4MfdqfrXg5XQwN36uRnNCEHEZg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, lkp <lkp@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "kbuild-all@01.org" <kbuild-all@01.org>

> Subject: Re: [kbuild-all] [linux-next:master 5885/8111] /tmp/cc3gKKeM.s:3=
5:
> Error: .err encountered
>=20
> On Sun, May 20, 2018 at 9:15 PM, kbuild test robot <lkp@intel.com> wrote:
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next=
.git master
> > head:   fbbe3b8c2c9c5f84caf668703c26154cb4fbb9d1
> > commit: 3b67022379d3d0c6a5cc5152f6b46eeea635a194 [5885/8111] arm: port
> KCOV to arm
> > config: arm-allmodconfig (attached as .config)
> > compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-
> tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout 3b67022379d3d0c6a5cc5152f6b46eeea635a194
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=3Darm
> >
> > All errors (new ones prefixed by >>):
> >
> >    /tmp/cc3gKKeM.s: Assembler messages:
> >>> /tmp/cc3gKKeM.s:35: Error: .err encountered
> >    /tmp/cc3gKKeM.s:36: Error: .err encountered
> >    /tmp/cc3gKKeM.s:37: Error: .err encountered
>=20
> I've tried to reproduce this following the instructions, but I failed,
thanks for input, we will follow up this to see whether there's issue
in bot side.

> build succeeds for me:
> https://www.spinics.net/lists/linux-mm/msg152336.html
> _______________________________________________
> kbuild-all mailing list
> kbuild-all@lists.01.org
> https://lists.01.org/mailman/listinfo/kbuild-all
