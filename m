Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1B21C6B0003
	for <linux-mm@kvack.org>; Sun, 20 May 2018 20:48:35 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id e1-v6so7537605pld.23
        for <linux-mm@kvack.org>; Sun, 20 May 2018 17:48:35 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id e1-v6si13288982plk.397.2018.05.20.17.48.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 17:48:33 -0700 (PDT)
From: "Li, Philip" <philip.li@intel.com>
Subject: RE: [kbuild-all] [mmotm:master 149/199] lib/idr.c:583:2: error:
 implicit declaration of function 'xa_lock_irqsave'; did you mean
 'read_lock_irqsave'?
Date: Mon, 21 May 2018 00:48:29 +0000
Message-ID: <831EE4E5E37DCC428EB295A351E662494CB2C11A@shsmsx102.ccr.corp.intel.com>
References: <201805190415.2D1H4m65%fengguang.wu@intel.com>
 <20180518151000.93517f28f3338bb39f558a90@linux-foundation.org>
 <20180519143139.2bryoecv4qwbhgtr@wfg-t540p.sh.intel.com>
In-Reply-To: <20180519143139.2bryoecv4qwbhgtr@wfg-t540p.sh.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wu, Fengguang" <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: lkp <lkp@intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Linux
 Memory Management List <linux-mm@kvack.org>, "kbuild-all@01.org" <kbuild-all@01.org>, Johannes Weiner <hannes@cmpxchg.org>

> Subject: Re: [kbuild-all] [mmotm:master 149/199] lib/idr.c:583:2: error: =
implicit
> declaration of function 'xa_lock_irqsave'; did you mean 'read_lock_irqsav=
e'?
>=20
> Hi Andrew,
>=20
> On Fri, May 18, 2018 at 03:10:00PM -0700, Andrew Morton wrote:
> >On Sat, 19 May 2018 04:21:17 +0800 kbuild test robot <lkp@intel.com> wro=
te:
> >
> >> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> >> head:   7400fc6942aefa2e009272d0e118284f110c5088
> >> commit: d5f90621ff2af7f139b01b7bcf8649a91665965e [149/199] lib/idr.c:
> remove simple_ida_lock
> >> config: x86_64-randconfig-i0-201819 (attached as .config)
> >> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> >> reproduce:
> >>         git checkout d5f90621ff2af7f139b01b7bcf8649a91665965e
> >>         # save the attached .config to linux build tree
> >>         make ARCH=3Dx86_64
> >>
> >> Note: the mmotm/master HEAD 7400fc6942aefa2e009272d0e118284f110c5088
> builds fine.
> >>       It only hurts bisectibility.
> >>
> >
> >I'm a bit surprised we're seeing this.
> >ida-remove-simple_ida_lock.patch introduces this error, and the very
> >next patch ida-remove-simple_ida_lock-fix.patch fixes it.
> >
> >I'm pretty sure that the robot software is capable of detecting this
> >situation and ignoring the error.  Did that code get broken?
>=20
> Yes sorry, the robot code looks not reliable when testing the follow
> up -fix patches. The check is done when first seeing the error instead
> of before sending out the final report. In the 2 cases, the next patch
> of the error commit could be subtly different.
>=20
> Shun Hao: to be 100% reliable, we'll also need to check the follow up
> -fix patches just before sending out the report.
thanks, we will follow up this to consider this situation.

>=20
> Thanks,
> Fengguang
> _______________________________________________
> kbuild-all mailing list
> kbuild-all@lists.01.org
> https://lists.01.org/mailman/listinfo/kbuild-all
