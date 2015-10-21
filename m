Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5B46B82F65
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 04:53:20 -0400 (EDT)
Received: by wikq8 with SMTP id q8so82790524wik.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 01:53:19 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id md5si10103434wjb.79.2015.10.21.01.53.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 01:53:19 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] fixup! mm: simplify reclaim path for MADV_FREE
Date: Wed, 21 Oct 2015 10:47:16 +0200
Message-ID: <5799761.gmbM76C6JW@wuerfel>
In-Reply-To: <56273fe6.c8afc20a.628d8.ffff9ed8@mx.google.com>
References: <56273fe6.c8afc20a.628d8.ffff9ed8@mx.google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-build-reports@lists.linaro.org
Cc: "kernelci. org bot" <bot@kernelci.org>, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wednesday 21 October 2015 00:33:58 kernelci. org bot wrote:
> lpc18xx_defconfig (arm) =E2=80=94 FAIL, 55 errors, 18 warnings, 0 sec=
tion mismatches
>=20
> Errors:
>     include/linux/rmap.h:274:1: error: expected declaration specifier=
s or '...' before '{' token
>     include/linux/uaccess.h:88:13: error: storage class specified for=
 parameter '__probe_kernel_read'
>     include/linux/uaccess.h:99:53: error: storage class specified for=
 parameter 'probe_kernel_write'

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: e4f28388eb72 ("mm: simplify reclaim path for MADV_FREE")
---
Please fold into the original patch if you don't already have this.

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 978f65066fd5..853f4f3c6742 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -270,7 +270,7 @@ int rmap_walk(struct page *page, struct rmap_walk_c=
ontrol *rwc);
=20
 static inline int page_referenced(struct page *page, int is_locked,
 =09=09=09=09  struct mem_cgroup *memcg,
-=09=09=09=09  unsigned long *vm_flags,
+=09=09=09=09  unsigned long *vm_flags)
 {
 =09*vm_flags =3D 0;
 =09return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
