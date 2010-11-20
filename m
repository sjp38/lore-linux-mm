Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 872356B0087
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 19:30:22 -0500 (EST)
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering
 writeback
From: Dustin Kirkland <kirkland@canonical.com>
Reply-To: kirkland@canonical.com
In-Reply-To: <20101119232254.GA28151@thunk.org>
References: <1289996638-21439-1-git-send-email-walken@google.com>
	 <1289996638-21439-4-git-send-email-walken@google.com>
	 <20101117125756.GA5576@amd> <1290007734.2109.941.camel@laptop>
	 <AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
	 <20101117231143.GQ22876@dastard> <20101118133702.GA18834@infradead.org>
	 <alpine.LSU.2.00.1011180934400.3210@tigran.mtv.corp.google.com>
	 <20101119072316.GA14388@google.com>
	 <20101119145442.ddf0c0e8.akpm@linux-foundation.org>
	 <20101119232254.GA28151@thunk.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-pRpbJGsqVHszJYkyD81F"
Date: Fri, 19 Nov 2010 18:29:49 -0600
Message-ID: <1290212989.12760.87.camel@x201>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Ted Ts'o <tytso@mit.edu>, "kees.cook" <kees.cook@canonical.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>


--=-pRpbJGsqVHszJYkyD81F
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2010-11-19 at 18:22 -0500, Ted Ts'o wrote:
> On Fri, Nov 19, 2010 at 02:54:42PM -0800, Andrew Morton wrote:
> >=20
> > Dirtying all that memory at mlock() time is pretty obnoxious.
> > ...
> > So all that leaves me thinking that we merge your patches as-is.  Then
> > work out why users can fairly trivially use mlock to hang the kernel on
> > ext2 and ext3 (and others?)=20
>=20
> So at least on RHEL 4 and 5 systems, pam_limits was configured so that
> unprivileged processes could only mlock() at most 16k.  This was
> deemed enough so that programs could protect crypto keys.  The
> thinking when we added the mlock() ulimit setting was that
> unprivileged users could very easily make a nuisance of themselves,
> and grab way too much system resources, by using mlock() in obnoxious
> ways.
>=20
> I was just checking to see if my memory was correct, and to my
> surprise, I've just found that Ubuntu deliberately sets the memlock
> ulimit to be unlimited.  Which means that Ubuntu systems are
> completely wide open for this particular DOS attack.  So if you
> administer an Ubuntu-based server, it might be a good idea to make a
> tiny little change to /etc/security/limits.conf....
>=20
> 							- Ted

Kees,

Copying you into this thread, in case you'd like to respond from the
Ubuntu side.  Thanks for the heads-up, Ted.

--=20
:-Dustin

Dustin Kirkland
Canonical, LTD
kirkland@canonical.com
GPG: 1024D/83A61194

--=-pRpbJGsqVHszJYkyD81F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkznFnsACgkQs7pNXIOmEZTcTgCaAmTGO89rHQk9XW6t5Ecx7Hya
MRwAnAyVApmwthwP0mKPwiOtTflUnq26
=0kmz
-----END PGP SIGNATURE-----

--=-pRpbJGsqVHszJYkyD81F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
