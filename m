Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3FE6B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 05:54:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f4so8755061wme.21
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 02:54:49 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id 60si5829021wrp.1.2017.10.16.02.54.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 02:54:48 -0700 (PDT)
Date: Mon, 16 Oct 2017 11:54:47 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Message-ID: <20171016095447.GA4639@amd>
References: <20171012014611.18725-4-mike.kravetz@oracle.com>
 <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz>
 <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <20171015065856.GC3916@xo-6d-61-c0.localdomain>
 <20171016081804.yiqck2g4bwlbdqi6@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XsQoSWH+UP9D9v3l"
Content-Disposition: inline
In-Reply-To: <20171016081804.yiqck2g4bwlbdqi6@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2017-10-16 10:18:04, Michal Hocko wrote:
> On Sun 15-10-17 08:58:56, Pavel Machek wrote:
> > Hi!
> >=20
> > > Yes you wrote that already and my counter argument was that this gene=
ric
> > > posix interface shouldn't bypass virtual memory abstraction.
> > >=20
> > > > > > The contiguous allocations are particularly useful for the RDMA=
 API which
> > > > > > allows registering user space memory with devices.
> > > > >
> > > > > then make those devices expose an implementation of an mmap which=
 does
> > > > > that. You would get both a proper access control (via fd), accoun=
ting
> > > > > and others.
> > > >=20
> > > > There are numerous RDMA devices that would all need the mmap
> > > > implementation. And this covers only the needs of one subsystem. Th=
ere are
> > > > other use cases.
> > >=20
> > > That doesn't prevent providing a library function which could be reus=
ed
> > > by all those drivers. Nothing really too much different from
> > > remap_pfn_range.
> >=20
> > So you'd suggest using ioctl() for allocating memory?
>=20
> Why not using standard mmap on the device fd?

No, sorry, that's something very different work, right? Lets say I
have a disk, and I'd like to write to it, using continguous memory for
performance.

So I mmap(MAP_CONTIG) 1GB working of working memory, prefer some data
structures there, maybe recieve from network, then decide to write
some and not write some other.

mmap(sda) does something very different... Everything you write to
that mmap will eventually go to the disk, and you don't have complete
control when.

Also, you can do mmap(MAP_CONTIG) and use that to both disk and
network. That would not work with mmap(sda) and mmap(eth0)...

									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--XsQoSWH+UP9D9v3l
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnkgecACgkQMOfwapXb+vJgngCcCzYHX0fmHkOhE/joYCYp3Fa5
/SQAn0uQyszIUPiwNwtkp2C1AoYRwbhf
=mNEn
-----END PGP SIGNATURE-----

--XsQoSWH+UP9D9v3l--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
