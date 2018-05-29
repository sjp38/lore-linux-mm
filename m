Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4ED6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 11:38:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z5-v6so9224230pfz.6
        for <linux-mm@kvack.org>; Tue, 29 May 2018 08:38:04 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d77-v6si3156862pfb.262.2018.05.29.08.38.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 08:38:03 -0700 (PDT)
From: "Li, Philip" <philip.li@intel.com>
Subject: RE: [kbuild-all] [linux-stable-rc:linux-4.14.y 3879/4798]
 kernel//time/posix-timers.c:1231:1: note: in expansion of macro
 'COMPAT_SYSCALL_DEFINE4'
Date: Tue, 29 May 2018 15:37:59 +0000
Message-ID: <831EE4E5E37DCC428EB295A351E662494CB98CE2@shsmsx102.ccr.corp.intel.com>
References: <201805292323.ZKQwkUJy%fengguang.wu@intel.com>
 <20180529153252.GB521@tigerII.localdomain>
In-Reply-To: <20180529153252.GB521@tigerII.localdomain>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, lkp <lkp@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "kbuild-all@01.org" <kbuild-all@01.org>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>

> Subject: Re: [kbuild-all] [linux-stable-rc:linux-4.14.y 3879/4798] kernel=
//time/posix-
> timers.c:1231:1: note: in expansion of macro 'COMPAT_SYSCALL_DEFINE4'
>=20
> On (05/29/18 23:23), kbuild test robot wrote:
> > Hi Sergey,
> >
> > First bad commit (maybe !=3D root cause):
> >
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-st=
able-rc.git
> linux-4.14.y
> > head:   9fcb9d72e8a3a813caae6e2fac43a73603d75abd
> > commit: 8e99c881e497e7f7528f693c563e204ae888a846 [3879/4798]
> tools/lib/subcmd/pager.c: do not alias select() params
> > config: x86_64-acpi-redef (attached as .config)
> > compiler: gcc-8 (Debian 8.1.0-3) 8.1.0
> > reproduce:
> >         git checkout 8e99c881e497e7f7528f693c563e204ae888a846
> >         # save the attached .config to linux build tree
> >         make ARCH=3Dx86_64
>=20
> Hello,
>=20
> The commit in question is for a user space tool. I don't think it has
> anything to do with the __SYSCALL_DEFINEx macro.
thanks for info, we also got similar "false" warning in other report, for n=
ow, I will
roll back to gcc-7.3, and do more check for 8.1.

>=20
> Seems that you have switched to gcc-8.1, which has aliasing warning ON
> by default.
>=20
> 	-ss
> _______________________________________________
> kbuild-all mailing list
> kbuild-all@lists.01.org
> https://lists.01.org/mailman/listinfo/kbuild-all
