Date: Wed, 27 Nov 2002 21:24:42 +0100
From: Rasmus Andersen <rasmus@jaquet.dk>
Subject: Re: 2.5.49-mm2
Message-ID: <20021127212442.B8411@jaquet.dk>
References: <3DE48C4A.98979F0C@digeo.com> <20021127210153.A8411@jaquet.dk> <3DE526FC.3D78DB54@digeo.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-md5;
	protocol="application/pgp-signature"; boundary="MW5yreqqjyrRcusr"
Content-Disposition: inline
In-Reply-To: <3DE526FC.3D78DB54@digeo.com>; from akpm@digeo.com on Wed, Nov 27, 2002 at 12:11:40PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--MW5yreqqjyrRcusr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 27, 2002 at 12:11:40PM -0800, Andrew Morton wrote:
> > Debug: Sleeping function called from illegal context at include/
> > linux/rwsem.h:66
> > Call Trace: __might_sleep+0x54/0x58
> >            sys_mprotect+0x97/0x22b
> >            syscall_call+0x7/0xb
>=20
> Oh that's cute.  Looks like we've accidentally disabled preemption
> somewhere...
>=20
> > Unable to handle kernel paging request at virtual address 4001360c
>=20
> And once you do that, the pagefault handler won't handle pagefaults.
> =20
> > (I did not copy the rest but can reproduce at will.)
>=20
> Please do.  And tell how you're making it happen.

I'm booting my debian testing system, going into kdm.
Various versions as per my last mail.

Does your 'Please do' mean that you would like the rest of
oops?

> Is that .config still current?

The .config used for -mm2 is at www.jaquet.dk/kernel/config-2.5.49-mm2

> Does it go away if you turn off preemption?

I'll test that right away.

Regards,=20
  Rasmus

--MW5yreqqjyrRcusr
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.0 (GNU/Linux)

iD8DBQE95SoKlZJASZ6eJs4RAptAAJ41wNpu8Tw73QRdJ6hMN6CAACfh2gCfZ7Io
M8i2lZl2zmRMUBYKVQGjsfE=
=k7Bt
-----END PGP SIGNATURE-----

--MW5yreqqjyrRcusr--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
