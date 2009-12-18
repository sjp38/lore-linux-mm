Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACB26B006A
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 19:38:56 -0500 (EST)
MIME-Version: 1.0
Message-ID: <6160c200-144c-4cc0-b095-6fe27e9ee3a1@default>
Date: Thu, 17 Dec 2009 16:38:28 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Tmem [PATCH 4/5] (Take 3): Add mm buildfiles
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: dan.magenheimer@oracle.com, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, linux-mm@kvack.org, Rusty@rcsinet15.oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, alan@lxorguk.ukuu.org.uk, chris.mason@oracle.com, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

Tmem [PATCH 4/5] (Take 3): Add mm buildfiles

Add necessary Kconfig and Makefile changes to mm directory

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

 Kconfig                                  |   26 +++++++++++++++++++++
 Makefile                                 |    3 ++
 2 files changed, 29 insertions(+)

--- linux-2.6.32/mm/Kconfig=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/mm/Kconfig=092009-12-17 13:56:46.000000000 -0700
@@ -287,3 +287,29 @@ config NOMMU_INITIAL_TRIM_EXCESS
 =09  of 1 says that all excess pages should be trimmed.
=20
 =09  See Documentation/nommu-mmap.txt for more information.
+
+#
+# support for transcendent memory
+#
+config TMEM
+=09bool "Transcendent memory support"
+=09help
+=09  In a virtualized environment, allows unused and underutilized
+=09  system physical memory to be made accessible through a narrow
+=09  well-defined page-copy-based API.
+
+config CLEANCACHE
+=09bool "Cache clean pages in transcendent memory"
+=09depends on TMEM
+=09help
+=09  Allows the transcendent memory pool to be used to store clean
+=09  page-cache pages which, under some circumstances, will greatly
+=09  reduce paging and thus improve performance.
+
+config FRONTSWAP
+=09bool "Swap pages to transcendent memory"
+=09depends on TMEM
+=09help
+=09  Allows the transcendent memory pool to be used as a pseudo-swap
+=09  device which, under some circumstances, will greatly reduce
+=09  swapping and thus improve performance.
--- linux-2.6.32/mm/Makefile=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/mm/Makefile=092009-12-17 14:23:40.000000000 -0700
@@ -17,6 +17,9 @@ obj-y +=3D init-mm.o
=20
 obj-$(CONFIG_BOUNCE)=09+=3D bounce.o
 obj-$(CONFIG_SWAP)=09+=3D page_io.o swap_state.o swapfile.o thrash.o
+obj-$(CONFIG_TMEM)=09+=3D tmem.o
+obj-$(CONFIG_FRONTSWAP)=09+=3D frontswap.o
+obj-$(CONFIG_CLEANCACHE) +=3D cleancache.o
 obj-$(CONFIG_HAS_DMA)=09+=3D dmapool.o
 obj-$(CONFIG_HUGETLBFS)=09+=3D hugetlb.o
 obj-$(CONFIG_NUMA) =09+=3D mempolicy.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
