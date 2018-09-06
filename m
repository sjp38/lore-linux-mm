Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 283146B765B
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 22:34:27 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id g9-v6so4021346uam.17
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 19:34:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e67-v6sor810050vkh.214.2018.09.05.19.34.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 19:34:25 -0700 (PDT)
MIME-Version: 1.0
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Greentime Hu <green.hu@gmail.com>
Date: Thu, 6 Sep 2018 10:33:48 +0800
Message-ID: <CAEbi=3dKL1zOYc0DC3yXm=7srw6tUfx-JR=o9n4pVrGp+Sosug@mail.gmail.com>
Subject: Re: [RFC PATCH 00/29] mm: remove bootmem allocator
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org, mingo@redhat.com, mpe@ellerman.id.au, mhocko@suse.com, paul.burton@mips.com, Thomas Gleixner <tglx@linutronix.de>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux <sparclinux@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Mike Rapoport <rppt@linux.vnet.ibm.com> =E6=96=BC 2018=E5=B9=B49=E6=9C=886=
=E6=97=A5 =E9=80=B1=E5=9B=9B =E4=B8=8A=E5=8D=8812:04=E5=AF=AB=E9=81=93=EF=
=BC=9A
>
> Hi,
>
> These patches switch early memory managment to use memblock directly
> without any bootmem compatibility wrappers. As the result both bootmem an=
d
> nobootmem are removed.
>
> There are still a couple of things to sort out, the most important is the
> removal of bootmem usage in MIPS.
>
> Still, IMHO, the series is in sufficient state to post and get the early
> feedback.
>
> The patches are build-tested with defconfig for most architectures (I
> couldn't find a compiler for nds32 and unicore32) and boot-tested on x86
> VM.
>
Hi Mike,

There are nds32 toolchains.
https://mirrors.edge.kernel.org/pub/tools/crosstool/files/bin/x86_64/8.1.0/=
x86_64-gcc-8.1.0-nolibc-nds32le-linux.tar.gz
https://github.com/vincentzwc/prebuilt-nds32-toolchain/releases/download/20=
180521/nds32le-linux-glibc-v3-upstream.tar.gz

Sorry, we have no qemu yet.
