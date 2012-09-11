Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 97D866B0074
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 17:36:57 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so3480090wib.8
        for <linux-mm@kvack.org>; Tue, 11 Sep 2012 14:36:55 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC] memory-hotplug: remove MIGRATE_ISOLATE from free_area->free_list
In-Reply-To: <20120911010336.GC14205@bbox>
References: <1346830033-32069-1-git-send-email-minchan@kernel.org> <xa1t1uigpefc.fsf@mina86.com> <20120906020850.GA31615@bbox> <xa1tipbr9uie.fsf@mina86.com> <20120911010336.GC14205@bbox>
Date: Tue, 11 Sep 2012 23:36:48 +0200
Message-ID: <xa1tr4q8w8b3.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 11 2012, Minchan Kim wrote:
> I saw two bug report about MIGRATE_ISOALTE type and NR_FREE_PAGES account=
ing
> mistmatch problem until now and I think we can meet more problems
> in the near future without solving it.
>
> Maybe, [1] would be a solution but I really don't like to add new branch
> in hotpath, even MIGRATE_ISOLATE used very rarely.
> so, my patch is inpired. If there is another good idea that avoid
> new branch in hotpath and solve the fundamental problem, I will drop this
> patch.
>
> [1] http://permalink.gmane.org/gmane.linux.kernel.mm/85199.

Well...  I am still not convinced.

Than again you clearly have put some thought into it and, more
importantly, I'm not the one deciding whether this gets merged or
not, anyway. ;)

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

iQIcBAEBAgAGBQJQT67wAAoJECBgQBJQdR/0+cIQAIE1nwegXCV6WY+kBW/I6o16
07xXNU1XkGZhB37+6ysSWP4fJvj+8vUZXSgM9v1+5SK8KpvMLk+vL7QcRh3vyGBJ
PG7hQSBnjgjl6HF6pDTQugXrH9/CwqBsxb8QUGklZXUBCZPm0wj1oxkWlGVRrVRX
I8evcHOuu8KsfMsPsptRoTBCN/hM9sHmOiBrYn1/+YwiyB0x0v7jp5PJvvHbgcF4
/Rf4JUF8P0YXLed5ru8Ux/uUuHnGa0OOWpxPB9d1KoKZleduvZrn51hl95mNR8mn
yNBl186ExrAfvJUgKmuthQqQx+E/fOHeC6vSBDlsq6bV0MNP8TTpcSNrhbugG6K+
j8oKlk8uEq2fFFDf6pzVOn/Zt0phiiHp2U5UylGQgdsMQnFc1E6xGd1/1o4x2e6M
Al0MLsdeK8OXDIFTwfjSgLXeQUVp6pNs5zhixNzpHkDVRd01WL6XoW9HJscbxfQi
RxBvUhqBzKIEOndC2pGodnuMWUouD5CKy05SucKLxqAGhQGzp24/f80p37+ujW2f
/dUsIS78VYRNyEc06zWh+GSArmE6NEsm//Uj9c208a4PJfTtM5iN92Jcx7KPKK0X
OhycJTHr8Mx+02he0aAuGpLp2UgNaiObSThJq2/9MsqDNaprVHuaVgKoO0WTmPl+
okzgHxzvxJM8SApJoDwP
=NV0O
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
