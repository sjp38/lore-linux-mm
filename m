From: Thomas Schlichter <schlicht@uni-mannheim.de>
Subject: Re: 2.6.0-test8-mm1
Date: Tue, 21 Oct 2003 00:30:39 +0200
References: <20031020020558.16d2a776.akpm@osdl.org> <200310210001.08761.schlicht@uni-mannheim.de> <20031020151713.149bba88.akpm@osdl.org>
In-Reply-To: <20031020151713.149bba88.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_RIGl/utH4OLdsoz";
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200310210030.41121.schlicht@uni-mannheim.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-02=_RIGl/utH4OLdsoz
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 21 October 2003 00:17, Andrew Mortonwrote:
> Thomas Schlichter <schlicht@uni-mannheim.de> wrote:
> > On Monday 20 October 2003 23:48, Andrew Morton wrote:
> > > A colleague here has discovered that this crash is repeatable, but go=
es
> > > away when the radeon driver is disabled.
> > >
> > > Are you using that driver?
> >
> > No, I'm not... I use the vesafb driver. Do you think disabling this cou=
ld
> > cure the Oops?
>
> It might.  Could you test it please?

I will, but currently I compile 2.6.0-test8. I want to try if this works...
I also want to try test8-mm1 without the -Os patch, you never know... ;-)

> There's nothing in -mm which touches the inode list management code, so a
> random scribble or misbehaving driver is likely.

Yes, or some part of the kernel compiled false...
(After some problems with erlier gcc's I don't trust my curent 3.3.1 that=20
much...)

> > Btw. a similar Oops at the same place occours when the uhci-hcd module =
is
> > unloaded...
>
> How similar?

Very similar (I think it came from deactivate_super(), too), but it seems n=
ot=20
to be logged...

--Boundary-02=_RIGl/utH4OLdsoz
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQA/lGIRYAiN+WRIZzQRAuNHAJsE5cCQZP03GEzn7djR9jodM+wZYwCgmNr0
wfjLbmi9ob4mKqmr3gy1Now=
=CyUI
-----END PGP SIGNATURE-----

--Boundary-02=_RIGl/utH4OLdsoz--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
