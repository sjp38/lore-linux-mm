Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C36946B0273
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 06:15:18 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w132so7293650ita.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 03:15:18 -0800 (PST)
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com. [15.241.48.73])
        by mx.google.com with ESMTPS id k69si2384448oib.175.2016.11.15.03.15.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 03:15:17 -0800 (PST)
Subject: Re: [RFC PATCH v3 1/2] Add support for eXclusive Page Frame Ownership
 (XPFO)
References: <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-2-juerg.haefliger@hpe.com>
 <CAGXu5jKY56q3Kp+dB0i-jgo7UrujCqnqhzw80+n_7keioKxWkQ@mail.gmail.com>
From: Juerg Haefliger <juerg.haefliger@hpe.com>
Message-ID: <cdec912a-3e28-b610-31b9-105384867bbf@hpe.com>
Date: Tue, 15 Nov 2016 12:15:14 +0100
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKY56q3Kp+dB0i-jgo7UrujCqnqhzw80+n_7keioKxWkQ@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="MMA5n0WALLx3TQ9tiMHKXcQ7909wPUkXE"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, linux-x86_64@vger.kernel.org, vpk@cs.columbia.edu

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--MMA5n0WALLx3TQ9tiMHKXcQ7909wPUkXE
Content-Type: multipart/mixed; boundary="Hdqn216xR43vntA6rDQsbXD8mI2B2GFMR";
 protected-headers="v1"
From: Juerg Haefliger <juerg.haefliger@hpe.com>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
 linux-x86_64@vger.kernel.org, vpk@cs.columbia.edu
Message-ID: <cdec912a-3e28-b610-31b9-105384867bbf@hpe.com>
Subject: Re: [RFC PATCH v3 1/2] Add support for eXclusive Page Frame Ownership
 (XPFO)
References: <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-2-juerg.haefliger@hpe.com>
 <CAGXu5jKY56q3Kp+dB0i-jgo7UrujCqnqhzw80+n_7keioKxWkQ@mail.gmail.com>
In-Reply-To: <CAGXu5jKY56q3Kp+dB0i-jgo7UrujCqnqhzw80+n_7keioKxWkQ@mail.gmail.com>

--Hdqn216xR43vntA6rDQsbXD8mI2B2GFMR
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Sorry for the late reply, I just found your email in my cluttered inbox.

On 11/10/2016 08:11 PM, Kees Cook wrote:
> On Fri, Nov 4, 2016 at 7:45 AM, Juerg Haefliger <juerg.haefliger@hpe.co=
m> wrote:
>> This patch adds support for XPFO which protects against 'ret2dir' kern=
el
>> attacks. The basic idea is to enforce exclusive ownership of page fram=
es
>> by either the kernel or userspace, unless explicitly requested by the
>> kernel. Whenever a page destined for userspace is allocated, it is
>> unmapped from physmap (the kernel's page table). When such a page is
>> reclaimed from userspace, it is mapped back to physmap.
>>
>> Additional fields in the page_ext struct are used for XPFO housekeepin=
g.
>> Specifically two flags to distinguish user vs. kernel pages and to tag=

>> unmapped pages and a reference counter to balance kmap/kunmap operatio=
ns
>> and a lock to serialize access to the XPFO fields.
>=20
> Thanks for keeping on this! I'd really like to see it land and then
> get more architectures to support it.

Good to hear :-)


>> Known issues/limitations:
>>   - Only supports x86-64 (for now)
>>   - Only supports 4k pages (for now)
>>   - There are most likely some legitimate uses cases where the kernel =
needs
>>     to access userspace which need to be made XPFO-aware
>>   - Performance penalty
>=20
> In the Kconfig you say "slight", but I'm curious what kinds of
> benchmarks you've done and if there's a more specific cost we can
> declare, just to give people more of an idea what the hit looks like?
> (What workloads would trigger a lot of XPFO unmapping, for example?)

That 'slight' wording is based on the performance numbers published in th=
e referenced paper.

So far I've only run kernel compilation tests. For that workload, the big=
 performance hit comes from
disabling >4k page sizes (around 10%). Adding XPFO on top causes 'only' a=
nother 0.5% performance
penalty. I'm currently looking into adding support for larger page sizes =
to see what the real impact
is and then generate some more relevant numbers.

=2E..Juerg


> Thanks!
>=20
> -Kees
>=20



--Hdqn216xR43vntA6rDQsbXD8mI2B2GFMR--

--MMA5n0WALLx3TQ9tiMHKXcQ7909wPUkXE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYKu5DAAoJEHVMOpb5+LSMzQ8P+wWBd+Sen2m8U4Q7HjsdGCoB
9fHq5r8x/bt+WvqF2i8vMR5Txrfn/EoOAkxkOu8tYiq7ECnHSnETAR8NVR2ckp0M
cizhmBdOiiMcOUiLSnPGxEx9390Qdx5li0ODwqQS5dSa9qCkBbbv6qf7ri5CzDFH
VO+OIAHI/kChTi4baKENq3UNHh0+8s/M0dykDwStIjrDG4Nh+IcEWOeDvOBWZ5HG
qxZQEg20reipzZTcba7paJ/pJQZBuKg/AFdQW/RFBFK3O0JngWKp67ZmxSU7PHw+
xr9qpKy+N9Yk3q5id7q2f2zA7eq3a3uYTNC+8d7zc6KQJIofnCLX/3dtuIEwS9rR
QSxQIPtk2sFmPLy/kXpU2RihdIJijJtx7RmbW7KEiuUMwUO+dDjjwJul9SNxlYWg
gYjUxPAGP6jxfGL443YKNbss2e5KfIh6LXlJpbtnD0WEfYiI7Ef2Y2qRrXpCkcw/
Z2kBLojOJOn8HagkHJiiw8lTwgDm2+YNcUWQoDgaTK9xOoAfMssETJfFaiGt6hsG
7VJot9jHg33kSZDyiTVBV6nwmCkOqtgXINYj8Q82iRmWUKPq2VEQEWWlvg31N9eu
S1L7EFIaAzZvt+6qc/GCrjjQzgOz+En/UyfmPoojJ+A6dx8/gM6oWkOOZDsG614J
9rFANUbutWyZav73fc/L
=Wzyi
-----END PGP SIGNATURE-----

--MMA5n0WALLx3TQ9tiMHKXcQ7909wPUkXE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
