Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C3E016B0253
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 09:22:45 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id c36so1990006qtc.12
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 06:22:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b76sor6063439qkj.110.2017.10.17.06.22.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 06:22:44 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
In-Reply-To: <AM6PR0502MB378375AF8B569DBCCFE20D7DBD4C0@AM6PR0502MB3783.eurprd05.prod.outlook.com>
References: <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz> <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake> <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz> <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake> <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz> <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake> <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz> <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com> <20171016082456.no6ux63uy2rmj4fe@dhcp22.suse.cz> <0e238c56-c59d-f648-95fc-c8cb56c3652e@mellanox.com> <20171016123248.csntl6luxgafst6q@dhcp22.suse.cz> <AM6PR0502MB378375AF8B569DBCCFE20D7DBD4C0@AM6PR0502MB3783.eurprd05.prod.outlook.com>
Date: Tue, 17 Oct 2017 15:22:39 +0200
Message-ID: <xa1tlgk9c3j4.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guy Shattah <sguy@mellanox.com>, Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Oct 17 2017, Guy Shattah wrote:
> Are you going to be OK with kernel API which implements contiguous
> memory allocation?  Possibly with mmap style?  Many drivers could
> utilize it instead of having their own weird and possibly non-standard
> way to allocate contiguous memory.  Such API won't be available for
> user space.

What you describe sounds like CMA.  It may be far from perfect but it=E2=80=
=99s
there already and drivers which need contiguous memory can allocate it.

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
