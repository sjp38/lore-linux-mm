Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 71D614402ED
	for <linux-mm@kvack.org>; Sat, 19 Dec 2015 15:30:38 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l126so25106066wml.0
        for <linux-mm@kvack.org>; Sat, 19 Dec 2015 12:30:38 -0800 (PST)
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id ee2si36461194wjd.88.2015.12.19.12.30.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Dec 2015 12:30:37 -0800 (PST)
Date: Sat, 19 Dec 2015 20:30:35 +0000
From: Ben Hutchings <ben@decadent.org.uk>
Message-ID: <20151219203034.GR28542@decadent.org.uk>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="Idd68gPqKLz5+Ci0"
Content-Disposition: inline
Subject: [PATCH] mm: Fix missing #include in <linux/mmdebug.h>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: xen-devel@lists.xenproject.org


--Idd68gPqKLz5+Ci0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

The various VM_WARN_ON/VM_BUG_ON macros depend on those defined by
<linux/bug.h>.  Most users already include those, but not all; for
example:

  CC      arch/arm64/xen/../../arm/xen/grant-table.o
In file included from arch/arm64/include/../../arm/include/asm/xen/page.h:5=
:0,
                 from arch/arm64/include/asm/xen/page.h:1,
                 from include/xen/page.h:28,
                 from arch/arm64/xen/../../arm/xen/grant-table.c:33:
arch/arm64/include/asm/pgtable.h: In function 'set_pte_at':
arch/arm64/include/asm/pgtable.h:281:3: error: implicit declaration of func=
tion 'BUILD_BUG_ON_INVALID' [-Werror=3Dimplicit-function-declaration]
   VM_WARN_ONCE(!pte_young(pte),

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/mmdebug.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 877ef22..772362a 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -1,6 +1,7 @@
 #ifndef LINUX_MM_DEBUG_H
 #define LINUX_MM_DEBUG_H 1
=20
+#include <linux/bug.h>
 #include <linux/stringify.h>
=20
 struct page;

--Idd68gPqKLz5+Ci0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBVnW+aue/yOyVhhEJAQpOgg//W/p82foQx1m5yQSU4Es6WeBAi/zXBVpt
T3iIRTYQDt+BcdmDpve+wcaxBzygsGfskDBjpzBKOWLUkv470h6QAIAcGMAzGIXL
rTMmDDNDVvzcxQuxXquxbV4HU1kC1VAZ8imgg1A0nZ/UvPBHud0c0iE/pwBgs9D5
iVg4L49WoS+yqaBlxmaTY7JANKMM+ZxD2IHg31bpKLCBI/cQ9Pl5AdOrP3tVSvA8
F3QO1uJPAHem3LG0MIBWn7Wr7Kgpy/g3AhwEc0eBzVyA4xdQnKEoS+56OSBKyrjk
CCxmWdiIAheZEjquoLEef7ZZSfcii61HlkClJ9yO2L/GO9rQKe9LbZ0/WwuwyUW5
eYwo4oRvxS+i1+qew5GFeiCymjN6ta1FLK3n129z4/Fn+KXzqF+iinVZU5Nt7Hx8
pc+OeC872hRiYvbteMnoTDARiFi28BZxZMriwY0Y+L61L/ubhgASRKpRMe4jyCVD
uS8VJlFJg/1NNJkjFnum6OLdI8seg+ETnF9LtJf56MIafeFTWe3aof1duaTtuXCy
yWYSzMYOsV7CNpxZhKbgm8aHJMFVx9/QaYisRAKh3rJzYwQPUk8AjXkQ5Y+7FS0p
yWwASLCumBYLxWgtufEB3moJ4LB5mht6Um7feJUsJZNV7pVJa5tNpb8BR0MuBCfK
U/3BvVhXp9g=
=Qu9E
-----END PGP SIGNATURE-----

--Idd68gPqKLz5+Ci0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
