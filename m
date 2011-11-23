Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 618746B0095
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 16:17:14 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so2424412vcb.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 13:17:12 -0800 (PST)
References: <9AF7658D-FEDB-479A-8D4F-A54264363CB4@gmail.com> <op.v5ey7hv93l0zgt@mpn-glaptop>
In-Reply-To: <op.v5ey7hv93l0zgt@mpn-glaptop>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=utf-8
Message-Id: <DEF7AFA8-9119-4FD7-915E-FB8572F06F02@gmail.com>
Content-Transfer-Encoding: quoted-printable
From: Jean-Francois Dagenais <jeff.dagenais@gmail.com>
Subject: Re: use of alloc_bootmem for a PCI-e device
Date: Wed, 23 Nov 2011 16:21:15 -0500
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: linux-mm@kvack.org


On Nov 23, 2011, at 14:31, Michal Nazarewicz wrote:

> On Wed, 23 Nov 2011 20:30:30 +0100, Jean-Francois Dagenais =
<jeff.dagenais@gmail.com> wrote:
>> I am maintaining a kernel for an embedded product. We have an FPGA
>> acquisition device interfaced through PCI-e on different intel =
platforms.
>> The acquisition device needs an extra large physically contiguous =
memory
>> area to autonomously dump acquired data into.
>=20
> [...]
>=20
>> We are doing another incarnation of the product on an Atom E6xx which =
has
>> no such IOMMU and am looking into ways of allocating a huge chunk of =
ram.
>> Kind of like integrated gfx chips do with RAM, but I don't have the =
assistance
>> of the BIOS.
>=20
> One trick that you might try to use (even though it's a bit hackish) =
is to
> pass ram=3D### on Linux command line where the number passed is actual =
memory
> minus size of the buffer you need.  Other then that, you might take a =
look
> at CMA (CMAv17 it was sent last week or so to linux-mm) which in one =
of the
> initialisation steps needs to grab memory regions.
Thanks for that, I am looking into it.

Looks like it can do what I want. Are there any mainline merge plans?

Unless I am mistaken, because of SWIOTLB, only x86_32 is supported, =
correct?

Since I want to allocate the buffer once at startup, then keep it until =
shutdown,
can you suggest a simpler, less flexible alternative? (other than the =
boot args
method which I consider a fallback plan).

>=20
> --=20
> Best regards,                                         _     _
> .o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
> ..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D =
Nazarewicz    (o o)
> ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
Thanks for helping!=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
