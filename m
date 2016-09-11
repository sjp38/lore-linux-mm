Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 001E46B0038
	for <linux-mm@kvack.org>; Sun, 11 Sep 2016 16:50:04 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id h11so70502584oic.2
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 13:50:04 -0700 (PDT)
Received: from omzsmtpe01.verizonbusiness.com (omzsmtpe01.verizonbusiness.com. [199.249.25.210])
        by mx.google.com with ESMTPS id y130si16624293itf.18.2016.09.11.13.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Sep 2016 13:50:03 -0700 (PDT)
From: "Levin, Alexander" <alexander.levin@verizon.com>
Date: Sun, 11 Sep 2016 16:47:31 -0400
Subject: Re: [linux-stable-rc:linux-3.14.y 1941/4977]
 include/linux/irqdesc.h:80:33: error: 'NR_IRQS' undeclared here (not in a
 function)
Message-ID: <20160911204731.GB30805@sasha-lappy>
References: <201609120447.p6I9GrZF%fengguang.wu@intel.com>
In-Reply-To: <201609120447.p6I9GrZF%fengguang.wu@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: "Levin, Alexander" <alexander.levin@verizon.com>, "kbuild-all@01.org" <kbuild-all@01.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sun, Sep 11, 2016 at 04:06:50PM -0400, kbuild test robot wrote:
> Hi Sasha,
>=20
> FYI, the error/warning still remains.
>=20
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stab=
le-rc.git linux-3.14.y
> head:   b65f2f457c49b2cfd7967c34b7a0b04c25587f13
> commit: 017ff97daa4a7892181a4dd315c657108419da0c [1941/4977] kernel: add =
support for gcc 5

Please make it stop :(

I've introduced a commit to support gcc 5, and I'm guessing that in turn yo=
ur build system now probably builds using gcc 5 for anything past that poin=
t, right?

This causes new errors/warnings which appear to be caused by my commit, but=
 obviously aren't.

Can you please make the build system just ignore this commit if it gets bis=
ected?

--=20

Thanks,
Sasha=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
