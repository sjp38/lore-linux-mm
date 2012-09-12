Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 0B4376B00B6
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 06:32:57 -0400 (EDT)
Received: by weys10 with SMTP id s10so1092026wey.14
        for <linux-mm@kvack.org>; Wed, 12 Sep 2012 03:32:56 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/2] mm: refactor out __alloc_contig_migrate_alloc
In-Reply-To: <1347414231-31451-1-git-send-email-minchan@kernel.org>
References: <1347414231-31451-1-git-send-email-minchan@kernel.org>
Date: Wed, 12 Sep 2012 12:32:48 +0200
Message-ID: <xa1tmx0vh6pb.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 12 2012, Minchan Kim <minchan@kernel.org> wrote:
> __alloc_contig_migrate_alloc can be used by memory-hotplug so
> refactor out(move + rename as a common name) it into
> page_isolation.c.
>
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

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

iQIcBAEBAgAGBQJQUGTQAAoJECBgQBJQdR/0+XEP/icziRPERoSNxQUvAculm9F5
5jEvNJaKkvk//kp+wJQvR2+5SWvc9rrsRD//cgONGgBqbu2uFlkinsE0kn4sxjIh
w6hLPRi6BvOfmepfCz6tw4lVHlCU3ilgK39Cm/cN6vObYk8kY/b2LMGpRLWJQ16o
+ZSJhiirLZetGCqzt0JVbibSxWnhf4/P99f6WJ2xw0ukeYdv8Y4nWkzG3b3Z/mjo
F/cFegMqGxzVfa3YZPERMufF7e9L6jysW+9T37BXtDd6Hz0JRfWjMN5sUHXyyT79
auRLHylTBs3X/ekxS5Z0sjtCh0tdYjhFbrkNiU3M5fQysomoorYULWG5zMNt4dS7
jjR+RYk7kN1HBcUQwdk7+NWkly9O8/2VCUeP+zggLxSsJTAATf0ngiFPks5g/D2k
A7DLaWxdoPnpALxlVdv47Q0qGCV76GsitB8m9vVI9Ou/AZCO9qzpQLjN5KbTYqx+
NtvypcpOtr54cqColTg+U4ShCPMYP0xoocMQIaKy/se8iRMguBw6ScOAlpFx0cOy
n25u+0jf95IopF4mEQcceMdqzEtjSH92rWT8HgKYqP8G/zlJW5IGjbsSKog/Kqsw
VeIhJ/CjPFXm9vzyXv3+tD0EYdClPS+93AW01yURPa7NAk12xaGj8PvlFDs/PN9V
0wFbTPY2V7NBY+1eihNY
=xAm+
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
