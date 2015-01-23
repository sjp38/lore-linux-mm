Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8E32B6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 08:45:58 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id i8so6262453qcq.3
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 05:45:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i3si2019180qaf.39.2015.01.23.05.45.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 05:45:57 -0800 (PST)
Message-ID: <54C25083.7020603@redhat.com>
Date: Fri, 23 Jan 2015 14:45:39 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] zram: protect zram->stat race with init_lock
References: <1421992707-32658-1-git-send-email-minchan@kernel.org> <1421992707-32658-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1421992707-32658-2-git-send-email-minchan@kernel.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="iBVRAcOvgeqUu7hXE6xEwavCrhj59baHX"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--iBVRAcOvgeqUu7hXE6xEwavCrhj59baHX
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 01/23/2015 06:58 AM, Minchan Kim wrote:
> The zram->stat handling should be procted by init_lock.
> Otherwise, user could see stale value from the stat.
>=20
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Jerome Marchand <jmarchan@redhat.com>



--iBVRAcOvgeqUu7hXE6xEwavCrhj59baHX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUwlCDAAoJEHTzHJCtsuoCdIcIAJnBlfB3Mgo+kARUZ/tFtg+T
2MsDY32R0j59OXXLyo4B+fD0ge3WV0W8sX5JFjYmMAnI0bLBwo9RSWKyneLN22Ac
4zS2cVwSUCc2/3SB0v9RYWW/FLQ7XteXcqCXS7R99j0yjlQWZ+SJ311JsWnmMRk0
i1zFyMCNbM08/BFoekU7zUnuGZzaoTAr11rzm/7wbRS18ghJMMAr8kNBqwTLJ7te
+xCVafwPIlN17IwrCq2rJ3pRmdIizO0bYt7rMujn6ytfVLtN3Rgjqc2HTPOQuJdD
bXCeOLCaXh55zqC1VbmnHNkTY0TkDLXNo+eh88Lib5SQ2q7EwUAqVpxQQGAFazA=
=N7xA
-----END PGP SIGNATURE-----

--iBVRAcOvgeqUu7hXE6xEwavCrhj59baHX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
