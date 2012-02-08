Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id C6E296B13F0
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 03:56:28 -0500 (EST)
From: Toralf =?utf-8?q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Subject: Re: swap storm since kernel 3.2.x
Date: Wed, 8 Feb 2012 09:56:15 +0100
References: <201202041109.53003.toralf.foerster@gmx.de> <201202051107.26634.toralf.foerster@gmx.de> <CAJd=RBCvvVgWqfSkoEaWVG=2mwKhyXarDOthHt9uwOb2fuDE9g@mail.gmail.com>
In-Reply-To: <CAJd=RBCvvVgWqfSkoEaWVG=2mwKhyXarDOthHt9uwOb2fuDE9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201202080956.18727.toralf.foerster@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Johannes Stezenbach <js@sig21.net>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org


Hillf Danton wrote at 12:38:31
> 2012/2/5 Toralf F=C3=B6rster <toralf.foerster@gmx.de>:
> > Hillf Danton wrote at 05:45:40
> >=20
> >> Would you please try the patchset of Rik?
> >>=20
> >>          https://lkml.org/lkml/2012/1/26/374
> >=20
> > It doesn't applied successfully agains 3.2.3 (+patch +f 3.2.5)
> >=20
> > :-(
>=20
> That patchset already in -next tree, mind to try it with
> CONFIG_SLUB_DEBUG first disabled, and try again with it enabled?
>=20
> Hillf
I switched back to 3.0.20 in the mean while.

=46rom what I can tell is this:
If the system is under heavy I/O load and hasn't too much free RAM (git pul=
l,=20
svn update and RAM consuming BOINC applications) then kernel 3.0.20 handle=
=20
this somehow while 3.2.x run into a swap storm like.

=2D-=20
MfG/Sincerely
Toralf F=C3=B6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
