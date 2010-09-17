Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 432796B007B
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 02:01:14 -0400 (EDT)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: [PATCH v2] Document the new Anonymous field in smaps.
Date: Fri, 17 Sep 2010 11:34:02 +0530
References: <AANLkTini3k1hK-9RM6io0mOf4VoDzGpbUEpiv=WHfhEW@mail.gmail.com> <201009161135.00129.knikanth@suse.de> <alpine.DEB.2.00.1009160940330.24798@tigran.mtv.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1009160940330.24798@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201009171134.02771.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, Richard Guenther <rguenther@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Document the new Anonymous field in smaps.

Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

=2D--

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems=
/proc.txt
index a6aca87..b430576 100644
=2D-- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -370,17 +370,24 @@ Shared_Dirty:          0 kB
 Private_Clean:         0 kB
 Private_Dirty:         0 kB
 Referenced:          892 kB
+Anonymous:             0 kB
 Swap:                  0 kB
 KernelPageSize:        4 kB
 MMUPageSize:           4 kB
=20
=2DThe first  of these lines shows  the same information  as is displayed f=
or the
=2Dmapping in /proc/PID/maps.  The remaining lines show  the size of the ma=
pping,
+The first of these lines shows the same information as is displayed for the
+mapping in /proc/PID/maps. The remaining lines show the size of the mappin=
g,
 the amount of the mapping that is currently resident in RAM, the "proporti=
onal
 set size=E2=80=9D (divide each shared page by the number of processes shar=
ing it), the
 number of clean and dirty shared pages in the mapping, and the number of c=
lean
=2Dand dirty private pages in the mapping.  The "Referenced" indicates the =
amount
=2Dof memory currently marked as referenced or accessed.
+and dirty private pages in the mapping. Even pages which are part of
+MAP_SHARED mappings, but has only a single pte mapped i.e., used exclusive=
ly
+by a process is accounted as private and not as shared. The "Referenced"
+indicates the amount of memory currently marked as referenced or accessed.=
 The
+"Anonymous" shows the number of pages that is not associated with a file. =
Even
+mappings associated with a file can have anonymous pages. When the mapping=
 is
+MAP_PRIVATE and its pages are modified, the pages are COWed and marked as
+anonymous.
=20
 This file is only present if the CONFIG_MMU kernel configuration option is
 enabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
