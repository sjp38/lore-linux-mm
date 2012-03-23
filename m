Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 27F9F6B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 12:41:20 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <2d2c494d-64e3-4968-a406-a8ede7eb39bb@default>
Date: Fri, 23 Mar 2012 09:40:15 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [GIT PULL] staging: ramster: unbreak my heart
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, linux-mm@kvack.org

Hey Greg  --

The just-merged ramster staging driver was dependent on a cleanup patch in
cleancache, so was marked CONFIG_BROKEN until that patch could be
merged.  That cleancache patch is now merged (and the correct SHA of the
cleancache patch is 3167760f83899ccda312b9ad9306ec9e5dda06d4 rather than
the one shown in the comment removed in the patch below).

So remove the CONFIG_BROKEN now and the comment that is no longer true...

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

diff --git a/drivers/staging/ramster/Kconfig b/drivers/staging/ramster/Kcon=
fig
index 8b57b87..4af1f8d 100644
--- a/drivers/staging/ramster/Kconfig
+++ b/drivers/staging/ramster/Kconfig
@@ -1,10 +1,6 @@
-# Dependency on CONFIG_BROKEN is because there is a commit dependency
-# on a cleancache naming change to be submitted by Konrad Wilk
-# a39c00ded70339603ffe1b0ffdf3ade85bcf009a "Merge branch 'stable/cleancach=
e.v13'
-# into linux-next.  Once this commit is present, BROKEN can be removed
 config RAMSTER
 =09bool "Cross-machine RAM capacity sharing, aka peer-to-peer tmem"
-=09depends on (CLEANCACHE || FRONTSWAP) && CONFIGFS_FS=3Dy && !ZCACHE && !=
XVMALLOC && !HIGHMEM && BROKEN
+=09depends on (CLEANCACHE || FRONTSWAP) && CONFIGFS_FS=3Dy && !ZCACHE && !=
XVMALLOC && !HIGHMEM
 =09select LZO_COMPRESS
 =09select LZO_DECOMPRESS
 =09default n

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
