Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F1C9C6B01DD
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 07:01:12 -0400 (EDT)
Received: by wyb39 with SMTP id 39so815166wyb.14
        for <linux-mm@kvack.org>; Wed, 30 Jun 2010 04:01:10 -0700 (PDT)
Date: Wed, 30 Jun 2010 12:01:03 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH] Add munmap events to perf
Message-ID: <20100630110103.GA8216@us.ibm.com>
References: <1277748484-23882-1-git-send-email-ebmunson@us.ibm.com>
 <1277755486.3561.140.camel@laptop>
 <20100629083323.GA6917@us.ibm.com>
 <1277810866.1868.32.camel@laptop>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nFreZHaLTZJo0R7j"
Content-Disposition: inline
In-Reply-To: <1277810866.1868.32.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@elte.hu, paulus@samba.org, acme@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Blanchard <anton@samba.org>
List-ID: <linux-mm.kvack.org>


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 29 Jun 2010, Peter Zijlstra wrote:

> On Tue, 2010-06-29 at 09:33 +0100, Eric B Munson wrote:
> > On Mon, 28 Jun 2010, Peter Zijlstra wrote:
> >=20
> > > On Mon, 2010-06-28 at 19:08 +0100, Eric B Munson wrote:
> > > > This patch adds a new software event for munmaps.  It will allows
> > > > users to profile changes to address space.  munmaps will be tracked
> > > > with mmaps.
> > >=20
> > > Why?
> > >=20
> >=20
> > It is going to be used by a tool that will model memory usage over the
> > lifetime of a process.
>=20
> Wouldn't it be better to use some tracepoints for that instead? I want
> to keep the sideband data to a minimum required to interpret the sample
> data, and you don't need unmap events for that.
>=20
>=20

Sure, I will get it moved to a tracepoint event instead.

--=20
Eric B Munson
IBM Linux Technology Center
ebmunson@us.ibm.com


--nFreZHaLTZJo0R7j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkwrI+8ACgkQsnv9E83jkzr4WgCfQqLAuPW3/56uAF8bxSYeN6OG
5YYAnRTBBaJmmS6ubEGCs9ZuLbOpAtBN
=EmkR
-----END PGP SIGNATURE-----

--nFreZHaLTZJo0R7j--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
