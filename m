Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 47F0A6B0006
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 19:01:47 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id j60-v6so3262761qtb.8
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 16:01:47 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0113.outbound.protection.outlook.com. [104.47.36.113])
        by mx.google.com with ESMTPS id f34-v6si2991660qtb.125.2018.10.09.16.01.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Oct 2018 16:01:46 -0700 (PDT)
From: Paul Burton <paul.burton@mips.com>
Subject: Re: [PATCH] memblock: stop using implicit alignement to
 SMP_CACHE_BYTES
Date: Tue, 9 Oct 2018 23:01:40 +0000
Message-ID: <20181009230137.rju3lm2saou5xsa4@pburton-laptop>
References: <1538687224-17535-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1538687224-17535-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <E3554E11A6C0914FA9C02D46ED897C1C@namprd22.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>

Hi Mike,

On Fri, Oct 05, 2018 at 12:07:04AM +0300, Mike Rapoport wrote:
> When a memblock allocation APIs are called with align =3D 0, the alignmen=
t is
> implicitly set to SMP_CACHE_BYTES.
>=20
> Replace all such uses of memblock APIs with the 'align' parameter explici=
tly
> set to SMP_CACHE_BYTES and stop implicit alignment assignment in the
> memblock internal allocation functions.
>=20
>%
>=20
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

  Acked-by: Paul Burton <paul.burton@mips.com> # MIPS part

Thanks,
    Paul
