Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 84B8B6B041B
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 09:58:44 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id r45so12025345qte.6
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 06:58:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m62si1457323qkd.195.2017.04.06.06.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 06:58:43 -0700 (PDT)
Date: Thu, 6 Apr 2017 09:58:34 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <305282435.22336766.1491487114644.JavaMail.zimbra@redhat.com>
In-Reply-To: <8b5cbc13-7abe-f090-5485-8990d9a837ac@linux.vnet.ibm.com>
References: <20170405204026.3940-1-jglisse@redhat.com> <20170405204026.3940-2-jglisse@redhat.com> <8b5cbc13-7abe-f090-5485-8990d9a837ac@linux.vnet.ibm.com>
Subject: Re: [HMM 01/16] mm/memory/hotplug: add memory type parameter to
 arch_add/remove_memory
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

> > diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> > index 5f84433..0933261 100644
> > --- a/arch/powerpc/mm/mem.c
> > +++ b/arch/powerpc/mm/mem.c
> > @@ -126,14 +126,31 @@ int __weak remove_section_mapping(unsigned long
> > start, unsigned long end)
> >  =09return -ENODEV;
> >  }
> > =20
> > -int arch_add_memory(int nid, u64 start, u64 size, bool for_device)
> > +int arch_add_memory(int nid, u64 start, u64 size, enum memory_type typ=
e)
> >  {
> >  =09struct pglist_data *pgdata;
> > -=09struct zone *zone;
> >  =09unsigned long start_pfn =3D start >> PAGE_SHIFT;
> >  =09unsigned long nr_pages =3D size >> PAGE_SHIFT;
> > +=09bool for_device =3D false;
> > +=09struct zone *zone;
> >  =09int rc;
> > =20
> > +=09/*
> > +=09 * Each memory_type needs special handling, so error out on an
> > +=09 * unsupported type. In particular, MEMORY_DEVICE_UNADDRESSABLE
> > +=09 * is not supported on this architecture.
>=20
> The concept of MEMORY_DEVICE_UNADDRESSABLE has not been
> introduced yet in this patch if I read correctly.

Correct, i did not want to add comment to all the arch file in the patch
that add it because this is one of the most painful patch to rebase so
instead of having more patch that are problematic for rebase i just added
the proper comment ahead of time to make my constant rebasing easier.

Cheers,
J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
