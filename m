Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id BE0266B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 09:00:04 -0400 (EDT)
Received: by wgbdq12 with SMTP id dq12so1322219wgb.26
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 06:00:03 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC] memory-hotplug: remove MIGRATE_ISOLATE from free_area->free_list
In-Reply-To: <20120906020850.GA31615@bbox>
References: <1346830033-32069-1-git-send-email-minchan@kernel.org> <xa1t1uigpefc.fsf@mina86.com> <20120906020850.GA31615@bbox>
Date: Thu, 06 Sep 2012 14:59:53 +0200
Message-ID: <xa1tipbr9uie.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

> On Wed, Sep 05, 2012 at 07:28:23PM +0200, Michal Nazarewicz wrote:
>> If you ask me, I'm not convinced that this improves anything.

On Thu, Sep 06 2012, Minchan Kim wrote:
> At least, it removes MIGRATE_ISOLATE type in free_area->free_list
> which is very irony type as I mentioned. I really don't like such
> type in free_area. What's the benefit if we remain code as it is?
> It could make more problem in future.

I don't really see current situation as making more problems in the
future compared to this code.

You are introducing a new state for a page (ie. it's not in buddy, but
in some new limbo state) and add a bunch of new code and thus bunch of
new  bugs.  I don't see how this improves things over having generic
code that handles moving pages between free lists.

PS.  free_list does exactly what it says on the tin -> the pages are
free, ie. unallocated.  It does not say that they can be allocated. ;)

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBAgAGBQJQSJ5JAAoJECBgQBJQdR/0dbsP/1dKXsqBtAKfu9S+jlmbio6O
LlYrEC70r/wcKgsKhAqN8itfFLNrIKDxNhv/sz1aXuKrCTq8QkeQT6kZswgWb/Mp
8/E2L0Z6XXmSjqJnmiDwPmoGDGUCQivE2XIXVkVeafhcqg9Z0HnvWsvVflJu56S4
dmuFsaliqp9iEGQEA+HkYI8VnaXK3sHYhOcOiL2G/4yYVyIlJoH2Pp4AZopeQvKZ
vpCspAutB+HjTSpE6tJg/4LqhmWK6OwCFjBDAuBLmRVnUCqv1hyIMxz7c2bOObdT
1V9NHoMp0Gorzdky1J2rSH29EpugDavrx8f0kOrqzD6BqZhIno86RVHgTWEgCy8e
zbRfecvUoABz+T78M57FjedIghB9yK/CmtvWqGg9apRUuMk6J6znb1Rtbp1bRKmn
tKHkCjpBAW9faLT1EerHLvCEQmnvskV13phu3gDqEf5BWiDmASDz9Vso5zT4N1c9
SKqBpX4XLDL/evEELXM9qMgIHWG7mRJz+AHHaYDFFVheiIiyr0oGwtCFKpJDGkHh
Sf8hvc6ehGYuBCjyH79mkuznIPPDIaWR9yioEXEAq52GsVXt6Xxlgz+oIR8ZYUqC
GffYet3kmnbtX0wX6Z871YWbpk9lQTbaqDVg8OHkSwBM5x8PMVBUeSWNlE177QLd
f5UNFmstTAGmOYE4wqdT
=n5Wc
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
