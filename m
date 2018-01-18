Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 17F6A6B0069
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 03:24:47 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g187so5846243wmg.2
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 00:24:47 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id q103si5873325wrb.110.2018.01.18.00.24.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 00:24:45 -0800 (PST)
Date: Thu, 18 Jan 2018 09:24:44 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/1] Re: kernel BUG at fs/userfaultfd.c:LINE!
Message-ID: <20180118082444.GA28474@amd>
References: <20171222222346.GB28786@zzz.localdomain>
 <20171223002505.593-1-aarcange@redhat.com>
 <CACT4Y+av2MyJHHpPQLQ2EGyyW5vAe3i-U0pfVXshFm96t-1tBQ@mail.gmail.com>
 <20180117085629.GA20303@amd>
 <20180117232631.gniczgvil5lsml6p@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bp/iNruPH9dso1Pn"
Content-Disposition: inline
In-Reply-To: <20180117232631.gniczgvil5lsml6p@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs@googlegroups.com


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed 2018-01-17 15:26:31, Eric Biggers wrote:
> On Wed, Jan 17, 2018 at 09:56:29AM +0100, Pavel Machek wrote:
> > Hi!
> >=20
> > > > Andrea Arcangeli (1):
> > > >   userfaultfd: clear the vma->vm_userfaultfd_ctx if UFFD_EVENT_FORK
> > > >     fails
> > > >
> > > >  fs/userfaultfd.c | 20 ++++++++++++++++++--
> > > >  1 file changed, 18 insertions(+), 2 deletions(-)
> > >=20
> > > The original report footer was stripped, so:
> > >=20
> > > Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.co=
m>
> >=20
> > Please don't. We don't credit our CPUs, and we don't credit Qemu. We
> > credit humans.
>=20
> The difference is that unlike your CPU or QEMU, syzbot is a program speci=
fically
> written to find and report Linux kernel bugs.  And although Dmitry Vyukov=
 has
> done most of the work, syzkaller and syzbot have had many contributors, a=
nd you
> are welcome to contribute too: https://github.com/google/syzkaller

No.

Someone is responsible for sending those reports to lkml, and that
someone is not a program, that is a human being.

And that someone should be in the From: address, and he gets the
credit when it goes right, and blame when it gets wrong. Pick that
person. He is responsible for reviewing mails the bot sends (perhaps
adding information that would normally be there but syzbot is not yet
able to add it automatically -- such as what tree it is to the
subject), and he should act on replies.

> > > and we also need to tell syzbot about the fix with:
> > >=20
> > > #syz fix:
> > > userfaultfd: clear the vma->vm_userfaultfd_ctx if UFFD_EVENT_FORK fai=
ls
> >=20
> > Now you claimed you care about bugs being fixed. What about actually
> > testing Andrea's fix and telling us if it fixes the problem or not,
> > and maybe saying "thank you"?
>=20
> Of course the syzbot team cares about bugs being fixed, why else would th=
ey
> report them?

=46rom the emails it looks like the bot is doing that for fame.

> Nevertheless, at the end of the day, no matter how a bug is reported or w=
ho
> reports it, it is primarily the responsibility of the person patching the=
 bug to
> test their patch.=20

Umm. Really? That's not how it historically worked. You report a bug,
you are expected to care enough to do the testing. You also say a
"thank you" to person who fixes the bug. Just because.

And syzbot does not do any of that, and that's why human should be in
the loop.

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--bp/iNruPH9dso1Pn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlpgWcwACgkQMOfwapXb+vJgvgCfewlLgJgc3z7TIsLcKcqYmLkN
f2UAoKsUyghe5uO6om+u9CF9kX1+WXqV
=oUuh
-----END PGP SIGNATURE-----

--bp/iNruPH9dso1Pn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
