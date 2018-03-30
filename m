Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B593D6B0027
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 05:57:37 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z15so3989280wrh.10
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 02:57:37 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id d15si3007695wma.224.2018.03.30.02.57.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Mar 2018 02:57:36 -0700 (PDT)
Date: Fri, 30 Mar 2018 11:57:35 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH v2 0/2] Randomization of address chosen by mmap.
Message-ID: <20180330095735.GA15641@amd>
References: <1521736598-12812-1-git-send-email-blackzert@gmail.com>
 <20180330075508.GA21798@amd>
 <95EECC28-7349-4FB4-88BF-26E4CF087A0B@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KsGdsel6WgEHnImy"
Content-Disposition: inline
In-Reply-To: <95EECC28-7349-4FB4-88BF-26E4CF087A0B@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Smith <blackzert@gmail.com>
Cc: rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@synopsys.com, linux@armlinux.org.uk, tony.luck@intel.com, fenghua.yu@intel.com, jhogan@kernel.org, ralf@linux-mips.org, jejb@parisc-linux.org, Helge Deller <deller@gmx.de>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, nyc@holomorphy.com, viro@zeniv.linux.org.uk, arnd@arndb.de, gregkh@linuxfoundation.org, deepa.kernel@gmail.com, Michal Hocko <mhocko@suse.com>, hughd@google.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, akpm@linux-foundation.org, steve.capper@arm.com, punit.agrawal@arm.com, paul.burton@mips.com, aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com, keescook@chromium.org, bhsharma@redhat.com, riel@redhat.com, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, jglisse@redhat.com, willy@infradead.org, aarcange@redhat.com, oleg@redhat.com, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri 2018-03-30 12:07:58, Ilya Smith wrote:
> Hi
>=20
> > On 30 Mar 2018, at 10:55, Pavel Machek <pavel@ucw.cz> wrote:
> >=20
> > Hi!
> >=20
> >> Current implementation doesn't randomize address returned by mmap.
> >> All the entropy ends with choosing mmap_base_addr at the process
> >> creation. After that mmap build very predictable layout of address
> >> space. It allows to bypass ASLR in many cases. This patch make
> >> randomization of address on any mmap call.
> >=20
> > How will this interact with people debugging their application, and
> > getting different behaviours based on memory layout?
> >=20
> > strace, strace again, get different results?
> >=20
>=20
> Honestly I=E2=80=99m confused about your question. If the only one way fo=
r debugging=20
> application is to use predictable mmap behaviour, then something went wro=
ng in=20
> this live and we should stop using computers at all.

I'm not saying "only way". I'm saying one way, and you are breaking
that. There's advanced stuff like debuggers going "back in time".

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--KsGdsel6WgEHnImy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlq+Cg8ACgkQMOfwapXb+vJu0QCdEsEH77ETyX2HVZNSmFfJe/v+
DCwAnjMGWij1bTYek7//IiDd4px1ZWUT
=qmNi
-----END PGP SIGNATURE-----

--KsGdsel6WgEHnImy--
