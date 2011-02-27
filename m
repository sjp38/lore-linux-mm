Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C8708D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 00:41:58 -0500 (EST)
From: Ben Hutchings <ben@decadent.org.uk>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Sun, 27 Feb 2011 05:41:35 +0000
Message-ID: <1298785295.3069.61.camel@localhost>
Mime-Version: 1.0
Subject: [PATCH] mm: <asm-generic/pgtable.h> must include <linux/mm_types.h>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Commit e2cda322648122dc400c85ada80eaddbc612ef6a 'thp: add pmd mangling
generic functions' replaced some macros in <asm-generic/pgtable.h>
with inline functions.  If the functions are to be defined (not all
architectures need them) then struct vm_area_struct must be defined
first.  So include <linux/mm_types.h>.

Fixes a build failure seen in Debian:

  CC [M]  drivers/media/dvb/mantis/mantis_pci.o
In file included from /build/buildd-linux-2.6_2.6.38~rc6-1~experimental.1-a=
rmel-6J2ga4/linux-2.6-2.6.38~rc6/debian/build/source_armel_none/arch/arm/in=
clude/asm/pgtable.h:460,
                 from /build/buildd-linux-2.6_2.6.38~rc6-1~experimental.1-a=
rmel-6J2ga4/linux-2.6-2.6.38~rc6/debian/build/source_armel_none/drivers/med=
ia/dvb/mantis/mantis_pci.c:25:
/build/buildd-linux-2.6_2.6.38~rc6-1~experimental.1-armel-6J2ga4/linux-2.6-=
2.6.38~rc6/debian/build/source_armel_none/include/asm-generic/pgtable.h: In=
 function 'ptep_test_and_clear_young':
/build/buildd-linux-2.6_2.6.38~rc6-1~experimental.1-armel-6J2ga4/linux-2.6-=
2.6.38~rc6/debian/build/source_armel_none/include/asm-generic/pgtable.h:29:=
 error: dereferencing pointer to incomplete type

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/asm-generic/pgtable.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 31b6188..b4bfe33 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -4,6 +4,8 @@
 #ifndef __ASSEMBLY__
 #ifdef CONFIG_MMU
=20
+#include <linux/mm_types.h>
+
 #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 extern int ptep_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pte_t *ptep,
--=20
1.7.4.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
