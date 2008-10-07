Received: by ik-out-1112.google.com with SMTP id c21so2360508ika.6
        for <linux-mm@kvack.org>; Tue, 07 Oct 2008 04:29:44 -0700 (PDT)
Date: Tue, 7 Oct 2008 14:30:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RFC] shmat: introduce flag SHM_MAP_HINT
Message-ID: <20081007113050.GD5126@localhost.localdomain>
References: <20081007195837.5A6B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081007112119.GG20740@one.firstfloor.org> <20081007202127.5A74.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="AbQceqfdZEv+FvjW"
Content-Disposition: inline
In-Reply-To: <20081007202127.5A74.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--AbQceqfdZEv+FvjW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 07, 2008 at 08:26:03PM +0900, KOSAKI Motohiro wrote:
> > > Honestly, I don't like that qemu specific feature insert into shmem c=
ore.
> >=20
> > I wouldn't say it's a qemu specific interface.  While qemu would=20
> > be the first user I would expect more in the future. It's a pretty
> > obvious extension. In fact it nearly should be default, if the
> > risk of breaking old applications wasn't too high.
>=20
> hm, ok, i understand your intension.
> however, I think following code isn't self describing.
>=20
> 	addr =3D shmat(shmid, addr, SHM_MAP_HINT);
>=20
> because HINT is too generic word.
> I think we should find better word.
>=20
> SHM_MAP_NO_FIXED ?

I like it.
Andi?

--=20
Regards,  Kirill A. Shutemov
 + Belarus, Minsk
 + ALT Linux Team, http://www.altlinux.com/

--AbQceqfdZEv+FvjW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjrSGoACgkQbWYnhzC5v6oIrQCePh44jlU2+Rsdcpbw64WI3ejV
/2EAnjCuatvL6n54pDz+8YlsAgJ+OK2i
=FF+l
-----END PGP SIGNATURE-----

--AbQceqfdZEv+FvjW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
