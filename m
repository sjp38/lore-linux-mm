Date: Mon, 9 Oct 2000 18:26:51 +0200
From: Kurt Garloff <garloff@suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001009182651.S1679@garloff.etpnet.phys.tue.nl>
References: <Pine.LNX.4.21.0010061721520.13585-100000@duckman.distro.conectiva> <Pine.LNX.4.21.0010091159430.20087-100000@Megathlon.ESI>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-md5;
	protocol="application/pgp-signature"; boundary="yLfVvEQOBD/VeTNx"
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010091159430.20087-100000@Megathlon.ESI>; from marco@esi.it on Mon, Oct 09, 2000 at 12:12:02PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marco Colombo <marco@esi.it>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--yLfVvEQOBD/VeTNx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 09, 2000 at 12:12:02PM +0200, Marco Colombo wrote:
> On Fri, 6 Oct 2000, Rik van Riel wrote:
> [...]
> > They are niced because the user thinks them a bit less
> > important.=20
>=20
> Please don't, this assumption is quite wrong. I use nice just to be
> 'nice' to other users. I can run my *important* CPU hog simulation
> nice +10 in order to let other people get more CPU when the need it.
> But if you put the logic "niced =3D=3D not important" somewhere into the
> kernel, nobody will use nice anymore. I'd rather give a bonus to niced
> processes.

I could not agree more. Normally, you'd better kill a foreground task
(running nice 0) than selecting one of those background jobs for some
reasons:
* The foreground job can be restarted by the interactive user
  (Most likely, it will be only netscape anyway)
* The background job probably is the more useful one which has been running
  since a longer time (computations, ...)
* If we put any policy like this into the kernel at all, I'd rather
  encourage the usage of nice instead of discouraging it.

I assume here backgrd job =3D=3D niced job, which mostly is the case in rea=
lity.

Regards,
--=20
Kurt Garloff  <garloff@suse.de>                          Eindhoven, NL
GPG key: See mail header, key servers         Linux kernel development
SuSE GmbH, Nuernberg, FRG                               SCSI, Security

--yLfVvEQOBD/VeTNx
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.3 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE54fHKxmLh6hyYd04RAjGbAJ9NsoD5LauMkR9LB/MHd+V5xR77iACfa/ot
23YBGPXZNBF8mkVk44p5PvI=
=PGbk
-----END PGP SIGNATURE-----

--yLfVvEQOBD/VeTNx--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
