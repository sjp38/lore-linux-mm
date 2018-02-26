Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27BBC6B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 07:21:32 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id x6so7560158plr.7
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 04:21:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 136sor1761892pgc.248.2018.02.26.04.21.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 04:21:31 -0800 (PST)
Date: Mon, 26 Feb 2018 02:21:26 -1000
From: Joey Pabalinas <joeypabalinas@gmail.com>
Subject: [PATCH] mm/zsmalloc: strength reduce zspage_size calculation
Message-ID: <20180226122126.coxtwkv5bqifariz@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="7mhpi7vsyt344z2b"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, Joey Pabalinas <joeypabalinas@gmail.com>


--7mhpi7vsyt344z2b
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Replace the repeated multiplication in the main loop
body calculation of zspage_size with an equivalent
(and cheaper) addition operation.

Signed-off-by: Joey Pabalinas <joeypabalinas@gmail.com>

 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index c3013505c30527dc42..647a1a2728634b5194 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -821,15 +821,15 @@ static enum fullness_group fix_fullness_group(struct =
size_class *class,
  */
 static int get_pages_per_zspage(int class_size)
 {
+	int zspage_size =3D 0;
 	int i, max_usedpc =3D 0;
 	/* zspage order which gives maximum used size per KB */
 	int max_usedpc_order =3D 1;
=20
 	for (i =3D 1; i <=3D ZS_MAX_PAGES_PER_ZSPAGE; i++) {
-		int zspage_size;
 		int waste, usedpc;
=20
-		zspage_size =3D i * PAGE_SIZE;
+		zspage_size +=3D PAGE_SIZE;
 		waste =3D zspage_size % class_size;
 		usedpc =3D (zspage_size - waste) * 100 / zspage_size;
=20
--=20
2.16.2

--7mhpi7vsyt344z2b
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEKlZXrihdNOcUPZTNruvLfWhyVBkFAlqT+8YACgkQruvLfWhy
VBknzhAAtnEwRKPM+ZxbJSgwy7J86qbCe+5kAPdN7Ipd4QO0aGQquBKkOaJD/v/3
SsSd2oQaPtIAqukwO9b18SPrICUbysWxcK3WQVse0jx6qqw4amnUrlQDnKNf8ZII
qwaqz2grd0GBO91N6WHFSB4lGNtCOObt8ZDT8rDtQ4wZlXg0Qr5Mc4zH7MbECWcE
9UjTKqd/jbIxDawY8zzq0qyd/xVg3s4kJqkdpF9dXeUJetXjgvXtj99f507lFrgQ
BK8fL2MT3uQsNax6Ay6D7pzDWMULj/bivvr8KxliJGAGTAVx2g4rkCcMaQBZtB+s
WvH15FeUBtct2KMfpq8a9u6jOqpMaNVXSAtLW1aM3i0AIcONTYuSLXvsWjOta7SB
+6M2is0HyOXfk6CBQbZPzVFdMGoPRO8VncT+sGrWnRVzjhRqDUvbfkYDiSSFLTbi
1L4PjRJQOo2s+N297S7TRVVpuX3407FyUNalYD4/1PVs80H1q4oHMBvTJpWtJBnN
sjsLnimhqMk7wwGRjgajnLxXCeBB9g+bd8j5tyHv8hZ+dXtqQMnAiQ5Q6reKGT9/
CUGcDdH2ROA9w8ABYo8+8ebubUnj9OOWv2yaNz5KxrANuAv1OAQiob7S+aXwOya3
UBP809gCQyAYp6mIM6s9t3kjq0arJoAKrwllOlg2IuJ9LVufW64=
=3G7G
-----END PGP SIGNATURE-----

--7mhpi7vsyt344z2b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
