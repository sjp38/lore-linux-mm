Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 76A726B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 09:32:50 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s2so5759468pge.19
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 06:32:50 -0700 (PDT)
Received: from APC01-SG2-obe.outbound.protection.outlook.com (mail-oln040092253109.outbound.protection.outlook.com. [40.92.253.109])
        by mx.google.com with ESMTPS id o82si5400466pfj.249.2017.10.27.06.32.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 Oct 2017 06:32:48 -0700 (PDT)
From: ? ?? <weilongpingshu@hotmail.com>
Subject: [PATCH] bug:roundup_pow_of_two(size) will return 0     when size >
 2^63 because of overflow problem. fix:when size > max, return max. (when
 newsize > max will return max originally)
Date: Fri, 27 Oct 2017 13:32:45 +0000
Message-ID: <SG2PR01MB13282FE183A0EA24DE95EB84C05A0@SG2PR01MB1328.apcprd01.prod.exchangelabs.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: ? ?? <weilongpingshu@hotmail.com>

Signed-off-by: LongPing.WEI <weilongpingshu@hotmail.com>
---
 mm/readahead.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index c4ca702..4941f04 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -248,7 +248,12 @@ int force_page_cache_readahead(struct address_space *m=
apping, struct file *filp,
  */
 static unsigned long get_init_ra_size(unsigned long size, unsigned long ma=
x)
 {
-	unsigned long newsize =3D roundup_pow_of_two(size);
+	unsigned long newsize;
+
+	if (size > max)
+		return max;
+
+	newsize =3D roundup_pow_of_two(size);
=20
 	if (newsize <=3D max / 32)
 		newsize =3D newsize * 4;
--=20
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
