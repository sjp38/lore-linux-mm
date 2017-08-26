Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id ADC8D6810D7
	for <linux-mm@kvack.org>; Sat, 26 Aug 2017 00:11:48 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y14so2287882wrd.3
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 21:11:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v16si6446929wrg.456.2017.08.25.21.11.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 21:11:46 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Sat, 26 Aug 2017 14:11:33 +1000
Subject: Re: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
In-Reply-To: <20170825213936.GA13576@amd>
References: <20170728091904.14627-1-mhocko@kernel.org> <20170823175709.GA22743@xo-6d-61-c0.localdomain> <20170825063545.GA25498@dhcp22.suse.cz> <20170825072818.GA15494@amd> <20170825080442.GF25498@dhcp22.suse.cz> <20170825213936.GA13576@amd>
Message-ID: <87pobjhssq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 25 2017, Pavel Machek wrote:

> On Fri 2017-08-25 10:04:42, Michal Hocko wrote:
>> On Fri 25-08-17 09:28:19, Pavel Machek wrote:
>> > On Fri 2017-08-25 08:35:46, Michal Hocko wrote:
>> > > On Wed 23-08-17 19:57:09, Pavel Machek wrote:
>> [...]
>> > > > Dunno. < 1msec probably is temporary, 1 hour probably is not. If i=
t causes
>> > > > problems, can you just #define GFP_TEMPORARY GFP_KERNEL ? Treewide=
 replace,
>> > > > and then starting again goes not look attractive to me.
>> > >=20
>> > > I do not think we want a highlevel GFP_TEMPORARY without any meaning.
>> > > This just supports spreading the flag usage without a clear semantic
>> > > and it will lead to even bigger mess. Once we can actually define wh=
at
>> > > the flag means we can also add its users based on that new semantic.
>> >=20
>> > It has real meaning.
>>=20
>> Which is?
>
> "This allocation is temporary. It lasts milliseconds, not hours."

It isn't sufficient to give a rule for when GFP_TEMPORARY will be used,
you also need to explain (at least in general terms) how the information
will be used.  Also you need to give guidelines on whether the flag
should be set for allocation that will last seconds or minutes.

If we have a flag that doesn't have a well defined meaning that actually
affects behavior, it will not be used consistently, and if we ever
change exactly how it behaves we can expect things to break.  So it is
better not to have a flag, than to have a poorly defined flag.

My current thoughts is that the important criteria is not how long the
allocation will be used for, but whether it is reclaimable.  Allocations
that will only last 5 msecs are reclaimable by calling "usleep(5000)".
Other allocations might be reclaimable in other ways.  Allocations that
are not reclaimable may well be directed to a more restricted pool of
memory, and might be more likely to fail.  If we grew a strong
"reclaimable" concept, this 'temporary' concept that you want to hold on
to would become a burden.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmg9PcACgkQOeye3VZi
gbnK5w/9EFiM/vufiuEborcv/va48Ho01Xtn7ftlb/cUbUZq54NlcB5Q1Gku3xci
VEoRvQS1hUo3s8wAVOTWVKL/Q9d2MYl05CWNp7wk2WRdScI2/yT5WsfpNbAEc507
MiFFnZPV4iqCpKFghNJNZ44HYJYioSkLROP+9znnrDAHl9gbTsRwYJF59PtG3iua
lC6SwEnmL0n/AyERnMJJCSNl/1puQeI6Gs8mOYN9p6d2XlQoSyRkGfteih847udC
nV/pqS7xizZtCGX8SZNcATcKeCXvAH4oH4cw9CioxuKgxqTKZQoc2GB2Y+HSgTaT
+l4idps3j2xF/y3hsDWR+gN/FSntzMtOCeK9iom/cYG2+E234ON94TecYv95qo06
Sefqy4Sq4CGlI3hfH3c+nWiQOVF7HD2JPia/uEmcf9YDW5SLKelHxEiwlWbWHMEL
yQCXtai3Ydh8qbY+1YSvOP9Ta9MuFku6D2Zhzx0yxUSEnI+dITrtlC2TRMHRMB5J
crJQMgkxbSJVkomShEGujecMvzqFizKVVmzG6Y+2REw4eMV3f8f5kTrRn1p4jW8Y
U83y0z10RuL/O6uedD09Pp5W62M8zFMPHJugAcE8dXBLplDDDlUQpmZ/xSqIgCTT
2k//4RBV4m8B7cTURON6qJqPHZZfPtzx1zFqgifypvw8r++Id1w=
=oCgK
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
