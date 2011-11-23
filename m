Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0BC6B002D
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 14:32:00 -0500 (EST)
Received: by bke17 with SMTP id 17so2539899bke.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 11:31:57 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: use of alloc_bootmem for a PCI-e device
References: <9AF7658D-FEDB-479A-8D4F-A54264363CB4@gmail.com>
Date: Wed, 23 Nov 2011 20:31:55 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v5ey7hv93l0zgt@mpn-glaptop>
In-Reply-To: <9AF7658D-FEDB-479A-8D4F-A54264363CB4@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Jean-Francois Dagenais <jeff.dagenais@gmail.com>

On Wed, 23 Nov 2011 20:30:30 +0100, Jean-Francois Dagenais <jeff.dagenai=
s@gmail.com> wrote:
> I am maintaining a kernel for an embedded product. We have an FPGA
> acquisition device interfaced through PCI-e on different intel platfor=
ms.
> The acquisition device needs an extra large physically contiguous memo=
ry
> area to autonomously dump acquired data into.

[...]

> We are doing another incarnation of the product on an Atom E6xx which =
has
> no such IOMMU and am looking into ways of allocating a huge chunk of r=
am.
> Kind of like integrated gfx chips do with RAM, but I don't have the as=
sistance
> of the BIOS.

One trick that you might try to use (even though it's a bit hackish) is =
to
pass ram=3D### on Linux command line where the number passed is actual m=
emory
minus size of the buffer you need.  Other then that, you might take a lo=
ok
at CMA (CMAv17 it was sent last week or so to linux-mm) which in one of =
the
initialisation steps needs to grab memory regions.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
