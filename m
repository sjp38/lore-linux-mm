Date: Fri, 15 Oct 2004 09:29:39 +0200
From: Martin Waitz <tali@admingilde.org>
Subject: Re: [RESEND][PATCH 5/6] Provide a filesystem-specific sync'able page bit
Message-ID: <20041015072939.GK4072@admingilde.org>
References: <24461.1097780707@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="j3olVFx0FsM75XyV"
Content-Disposition: inline
In-Reply-To: <24461.1097780707@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--j3olVFx0FsM75XyV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

hi :)

On Thu, Oct 14, 2004 at 08:05:07PM +0100, David Howells wrote:
> +#define PG_fs_misc		 9	/* Filesystem specific bit */

name it PG_fs_private if it is intended to be used by the fs only?

--=20
Martin Waitz

--j3olVFx0FsM75XyV
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFBb3xij/Eaxd/oD7IRArWgAJ44hzBW6p61XUuDx/B2ITDa0uGpAgCeOP3r
CUZikRkRnhfOu/C/+jf1i1U=
=Y7di
-----END PGP SIGNATURE-----

--j3olVFx0FsM75XyV--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
