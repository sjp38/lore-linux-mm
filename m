Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 67D686B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 06:33:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t69so8780116wmt.7
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 03:33:12 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j9sor3346898edf.30.2017.10.16.03.33.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Oct 2017 03:33:10 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
In-Reply-To: <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
References: <20171012014611.18725-1-mike.kravetz@oracle.com> <20171012014611.18725-4-mike.kravetz@oracle.com> <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz> <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com> <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz> <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake> <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz> <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake> <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz> <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake> <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz> <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
Date: Mon, 16 Oct 2017 12:33:07 +0200
Message-ID: <xa1t60bfxtzw.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guy Shattah <sguy@mellanox.com>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On Sun, Oct 15 2017, Guy Shattah wrote:
> Why have several driver specific implementation if you can generalize
> the idea and implement an already existing POSIX standard?

Why is there a need for contiguous allocation?

CPU cares only to the point of huge pages and there=E2=80=99s already an ef=
fort
in the kernel to allocate huge pages transparently without user space
being aware of it.

If not CPU than various devices all of which may have very different
needs.  Some may be behind an IO MMU.  Some may support DMA.  Some may
indeed require physically continuous memory.  How is user space to know?

Furthermore, user space does not care whether allocation is physically
contiguous or not.  What it cares about is whether given allocation can
be passed as a buffer to a particular device.

If generalisation is the issue, then the solution is to define a common
API where user-space can allocate memory *in the context of* a device.
This provides a =E2=80=98give me memory I can use for this device=E2=80=99 =
request which
is what user space really wants.

So yeah, like others in this thread, the reason for this change alludes
me.  On the other hand, I don=E2=80=99t care much so I=E2=80=99ll limit mys=
elf to this
one message.

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=
=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
