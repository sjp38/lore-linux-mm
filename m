Date: Thu, 10 Jul 2008 21:05:43 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [RFC PATCH 0/5] kmemtrace RFC patch series
Message-ID: <20080710210543.1945415d@linux360.ro>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/eDwnV6WRwqHTy_eTG62OOwz";
 protocol="application/pgp-signature"; micalg=PGP-SHA1
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/eDwnV6WRwqHTy_eTG62OOwz
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi everybody,

I'd like to hear your opinion regarding kmemtrace and SL*B hooks.

This is just a RFC, it's not intended to be merged yet. The userspace
app is not included.

BTW, there may be some whitespace errors, but disregard them for now,
they will be fixed.

	Cheers,
	Eduard


Eduard - Gabriel Munteanu (5):
  kmemtrace: Core implementation.
  Add new GFP flag __GFP_NOTRACE.
  kmemtrace: SLAB hooks.
  kmemtrace: SLUB hooks.
  kmemtrace: SLOB hooks.

 MAINTAINERS               |    6 ++
 include/linux/gfp.h       |    1 +
 include/linux/kmemtrace.h |  110 +++++++++++++++++++++++
 include/linux/slab_def.h  |   16 +++-
 include/linux/slub_def.h  |    9 ++-
 init/main.c               |    2 +
 lib/Kconfig.debug         |    4 +
 mm/Makefile               |    2 +-
 mm/kmemtrace.c            |  213 +++++++++++++++++++++++++++++++++++++++++=
++++
 mm/slab.c                 |   35 ++++++--
 mm/slob.c                 |   37 +++++++--
 mm/slub.c                 |   49 +++++++++--
 12 files changed, 460 insertions(+), 24 deletions(-)
 create mode 100644 include/linux/kmemtrace.h
 create mode 100644 mm/kmemtrace.c

--Sig_/eDwnV6WRwqHTy_eTG62OOwz
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.7 (GNU/Linux)

iQIVAwUBSHZPe9xcOkuRpXptAQIEoxAAm444Y8rJaMlo7Ec39yTLJD8jZAHJ+hgB
NezFUKPPEXFcH8FU7jBwLqgfKMIOWQSPJ2ZJjaMUBtrlBQeh4OUCWuTEpbF0i+Im
3jF+IZ95nuTHuLnBqOa+o2YTlaBVGKgwEHJRGQVS9wMA0BRUNlF3WotIoysv2bxO
JLsVyxMUr86qsNsqoXmtumwqB9LieJ22WkBwWIi2kIHk/QfLcod0WTIJDJqyAfRa
2U017CeZDHjqBHvGic5lu7v2OLpm88dnwn9dUfnDBQipfguddPCgtjRKk7Wt3Xjs
+RAX+lfkikvKW1TF5lcz76LW/3kgIlawLxfZfBGNJg9VcStJl6OiKvu8BTbiXj8K
X5st20oKVpfeAirry6aPhZGogW2M47NotYIxNCUhu22oOx15sS3cFN/njhAhU2nF
0OG/ZdALXvIUcKd0ZgwpT1xZavzahn0jNtVM1vTCDwyFaLqo4hLuaro1JkzxbKLy
hpnnufD6Yk11sn4y8q7FyRsl52DnjGog3HArOXexxWEcM/12wfPz8dEbhw7DB50t
2PCip2noinZXjfWOvIHzCW7FTat6noCJzJG/H1h4aeIpRC6ysl+Q0VmjPhjNLlqm
QhnR63qTPr3t2EIOh7fbAJp3vjU+vTATKICMeh416v4fPrSyV/2DYyUbJz7EkPlJ
Mvn904ADjIU=
=dCP5
-----END PGP SIGNATURE-----

--Sig_/eDwnV6WRwqHTy_eTG62OOwz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
