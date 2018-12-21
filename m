Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DAE58E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 10:39:23 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id q3so6164056qtq.15
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 07:39:23 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id h88si1137907qtd.264.2018.12.21.07.39.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 07:39:22 -0800 (PST)
Date: Fri, 21 Dec 2018 10:39:17 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH v5 00/20] VM introspection
Message-ID: <20181221153917.GA8195@char.us.oracle.com>
References: <20181220182850.4579-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181220182850.4579-1-alazar@bitdefender.com>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>, linux-mm@kvack.org
Cc: kvm@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>

On Thu, Dec 20, 2018 at 08:28:30PM +0200, Adalbert Laz=C4=83r wrote:
> This patch series proposes a VM introspection subsystem for KVM (KVMi).
>=20
> The previous RFC can be read here: https://marc.info/?l=3Dkvm&m=3D15136=
2403331566
>=20
> This iteration brings, mostly:
>   - an improved remote mapping (moved to the mm/ tree)
>   - single-step support for #PF events and as an workaround to unimplem=
ented
>     instructions from the x86 emulator that may need to be handled on E=
PT
>     violations VMEXITS
>   - a new ioctl to allow the introspection tool to remove its hooks fro=
m
>     guest before it is suspended or live migrated

.. No mention of the libvmi tool - are you going to provide the functiona=
lity
in there as well to use these new ioctls? Would it make sense to CC the l=
ibvmi
community as well to get their input?

>   - more bugfixes and a lot of stability
>=20
> Still not implemented yet (even if some are documented) are virtualized
> exceptions, EPT views and SPP (Sub Page Protection).
>=20
> We're still looking forward to add kvm unit tests for this VM
> introspection system now that we've integrated it in our products and
> in our internal tests framework.

..snip..>=20

>  mm/Kconfig                               |    9 +
>  mm/Makefile                              |    1 +
>  mm/gup.c                                 |    1 +
>  mm/huge_memory.c                         |    1 +
>  mm/internal.h                            |    5 -
>  mm/mempolicy.c                           |    1 +
>  mm/mmap.c                                |    1 +
>  mm/mmu_notifier.c                        |    1 +
>  mm/pgtable-generic.c                     |    1 +
>  mm/remote_mapping.c                      | 1438 ++++++++++++++
>  mm/rmap.c                                |   39 +-
>  mm/swapfile.c                            |    1 +

Please make sure to CC linux-mm@kvack.org when posting this.

In the meantime for folks on linux-mm, pls see https://www.spinics.net/li=
sts/kvm/msg179441.html
