Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3850D6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 08:07:55 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id 10so5721268lbg.6
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 05:07:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bw9si2962189wjc.74.2015.01.23.05.07.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 05:07:53 -0800 (PST)
Message-ID: <54C2479A.3080307@redhat.com>
Date: Fri, 23 Jan 2015 14:07:38 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] zram: free meta out of init_lock
References: <1421992707-32658-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1421992707-32658-1-git-send-email-minchan@kernel.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="pDPdHvHteOPovA7cqvEq4NPjlCUs6Glgm"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--pDPdHvHteOPovA7cqvEq4NPjlCUs6Glgm
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 01/23/2015 06:58 AM, Minchan Kim wrote:
> We don't need to call zram_meta_free, zcomp_destroy and zs_free
> under init_lock. What we need to prevent race with init_lock
> in reset is setting NULL into zram->meta (ie, init_done).
> This patch does it.
>=20
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

On a side note, when zram->meta replaced init_done, no comment was
added in zram structure to explain that. Things could be made more
explicit.

---
Subject: [PATCH] zram: explicitely state that zram->meta is used to deter=
mine
 the init state

zram->meta is used to determine the initialization state of a zram struct=
ure.
This patch adds a comment to zram structure to make this clear.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 drivers/block/zram/zram_drv.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.=
h
index b05a816..551569a 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -99,7 +99,7 @@ struct zram_meta {
 };
=20
 struct zram {
-	struct zram_meta *meta;
+	struct zram_meta *meta;	/* also used to determine the init state */
 	struct request_queue *queue;
 	struct gendisk *disk;
 	struct zcomp *comp;
--=20
1.9.3


--pDPdHvHteOPovA7cqvEq4NPjlCUs6Glgm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUwkeaAAoJEHTzHJCtsuoCydsH/A5GbUNu7fbCyxXJBma0Edma
/S2z+15ch/htCY1euoL2zenPePk/HjlEYYKz8d57HwmeE8ajE47aYwX/Bdk8s2ZN
RcBKu3KCZRXxTz11IAS1pCCLL0Uk+OcPlv+O7gl3XlwFw1z+275poWp1gDWrEXzi
yu0cqD65xLcwA7jnmwYXjjh4bY08+KCxSUKsUJYFleeEvAp4mU5cDWBkPU+ytMGc
Pg9gqzSVChIlE/4A7AAXBoiqRWJXthZrTuC6oQcKCB/AMQ71xg0gvdo0sUG77Mm2
xSzveZVLnu40bXuqUyLckYbPBky30LeHfi6n9ZWySjH118k1WEyNPmaIjP/oBEs=
=YhRf
-----END PGP SIGNATURE-----

--pDPdHvHteOPovA7cqvEq4NPjlCUs6Glgm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
