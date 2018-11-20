Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 90B066B21B7
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 15:07:22 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w19-v6so3097111plq.1
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 12:07:22 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id d4-v6si45169085pla.2.2018.11.20.12.07.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Nov 2018 12:07:20 -0800 (PST)
Date: Wed, 21 Nov 2018 07:07:06 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH -next 1/2] mm/memfd: make F_SEAL_FUTURE_WRITE seal more
 robust
Message-ID: <20181121070658.011d576d@canb.auug.org.au>
In-Reply-To: <20181120183926.GA124387@google.com>
References: <20181120052137.74317-1-joel@joelfernandes.org>
	<CALCETrXgBENat=5=7EuU-ttQ-YSXT+ifjLGc=hpJ=unRgSsndw@mail.gmail.com>
	<20181120183926.GA124387@google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ooUNGYHyJAbidRTGc1JxAN0"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, Linux API <linux-api@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, marcandre.lureau@redhat.com, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Shuah Khan <shuah@kernel.org>

--Sig_/ooUNGYHyJAbidRTGc1JxAN0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Joel,

On Tue, 20 Nov 2018 10:39:26 -0800 Joel Fernandes <joel@joelfernandes.org> =
wrote:
>
> On Tue, Nov 20, 2018 at 07:13:17AM -0800, Andy Lutomirski wrote:
> > On Mon, Nov 19, 2018 at 9:21 PM Joel Fernandes (Google)
> > <joel@joelfernandes.org> wrote: =20
> > >
> > > A better way to do F_SEAL_FUTURE_WRITE seal was discussed [1] last we=
ek
> > > where we don't need to modify core VFS structures to get the same
> > > behavior of the seal. This solves several side-effects pointed out by
> > > Andy [2].
> > >
> > > [1] https://lore.kernel.org/lkml/20181111173650.GA256781@google.com/
> > > [2] https://lore.kernel.org/lkml/69CE06CC-E47C-4992-848A-66EB23EE6C74=
@amacapital.net/
> > >
> > > Suggested-by: Andy Lutomirski <luto@kernel.org>
> > > Fixes: 5e653c2923fd ("mm: Add an F_SEAL_FUTURE_WRITE seal to memfd") =
=20
> >=20
> > What tree is that commit in?  Can we not just fold this in? =20
>=20
> It is in linux-next. Could we keep both commits so we have the history?

Well, its in Andrew's mmotm, so its up to him.

--=20
Cheers,
Stephen Rothwell

--Sig_/ooUNGYHyJAbidRTGc1JxAN0
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlv0aWoACgkQAVBC80lX
0GzyDwgAnINJOo+z0k5/uEZUNf1WTX20DuqXkwO5M+usRMxeraxGHTcP0NqYzcE7
tnsF/WBGwqXOrB0//rRttyqg9oHKCZatgDs5SUPIaPXuSCSc8/72uWZxNleiHnMQ
CjQwVZbxXzQU1aNT5hplpctUU1Y/MEMqPivy3pcUAPowvbGIYh2TM5OFvIQxqeyU
hhRDUzS2ijhyxE65IzYbE9+a90YkBliE0GcR3+92Lfs2+dafP+VI0ExM95niyNaP
TFYDevRCS7JwDx4ASR07wsbs1Vs9Y4nA3ZGyCDMVogbqBEx+VQQaGpgwTtkvJhhb
m6MpQMsDAMHBBs/2I1f53tSwtuh0kg==
=2jN8
-----END PGP SIGNATURE-----

--Sig_/ooUNGYHyJAbidRTGc1JxAN0--
