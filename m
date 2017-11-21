Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id AEB766B0033
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 09:48:12 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id n3so7023054qkn.9
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 06:48:12 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e35si4504405qta.178.2017.11.21.06.48.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 06:48:11 -0800 (PST)
Message-ID: <1511275666.14446.1.camel@oracle.com>
Subject: Re: [PATCH v1] mm: relax deferred struct page requirements
From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Tue, 21 Nov 2017 07:47:46 -0700
In-Reply-To: <20171117014601.31606-1-pasha.tatashin@oracle.com>
References: <20171117014601.31606-1-pasha.tatashin@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, arbab@linux.vnet.ibm.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, linuxppc-dev@lists.ozlabs.org, mhocko@suse.com, linux-mm@kvack.org, linux-s390@vger.kernel.org, mgorman@techsingularity.net

On Thu, 2017-11-16 at 20:46 -0500, Pavel Tatashin wrote:
> There is no need to have ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT,
> as all the page initialization code is in common code.
>=20
> Also, there is no need to depend on MEMORY_HOTPLUG, as initialization
> code
> does not really use hotplug memory functionality. So, we can remove
> this
> requirement as well.
>=20
> This patch allows to use deferred struct page initialization on all
> platforms with memblock allocator.
>=20
> Tested on x86, arm64, and sparc. Also, verified that code compiles on
> PPC with CONFIG_MEMORY_HOTPLUG disabled.
>=20
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
> =C2=A0arch/powerpc/Kconfig | 1 -
> =C2=A0arch/s390/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0| 1 -
> =C2=A0arch/x86/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 1 -
> =C2=A0mm/Kconfig=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0| 7 +------
> =C2=A04 files changed, 1 insertion(+), 9 deletions(-)
>=20
>=20

Looks reasonable to me.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
