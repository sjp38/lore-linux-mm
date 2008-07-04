Date: Fri, 4 Jul 2008 19:58:00 +0200
From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: How to alloc highmem page below 4GB on i386?
Message-ID: <20080704195800.4ef6e00a@mjolnir.drzeus.cx>
In-Reply-To: <20080630200323.2a5992cd@mjolnir.drzeus.cx>
References: <20080630200323.2a5992cd@mjolnir.drzeus.cx>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=PGP-SHA1; boundary="=_freyr.drzeus.cx-876-1215193601-0001-2"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-876-1215193601-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 30 Jun 2008 20:03:23 +0200
Pierre Ossman <drzeus-list@drzeus.cx> wrote:

> Simple question. How do I allocate a page from highmem, that's still
> within 32 bits? x86_64 has the DMA32 zone, but i386 has just HIGHMEM.
> As most devices can't DMA above 32 bit, I have 3 GB of memory that's
> not getting decent usage (or results in needless bouncing). What to do?
>=20
> I tried just enabling CONFIG_DMA32 for i386, but there is some guard
> against too many memory zones. I'm assuming this is there for a good
> reason?
>=20

Anyone?

--=20
     -- Pierre Ossman

  Linux kernel, MMC maintainer        http://www.kernel.org
  rdesktop, core developer          http://www.rdesktop.org

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-876-1215193601-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iEYEARECAAYFAkhuZLAACgkQ7b8eESbyJLi5dgCeIw6rCoDUDfvdqEZ6lwQFtT70
hpoAn3RAVQ0OFZMSSF3OnMYq4U/aHtI0
=NFbH
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-876-1215193601-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
