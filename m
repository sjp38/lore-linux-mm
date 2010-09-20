Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A70EE6B0047
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 03:11:40 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o8K7BXBm025136
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 00:11:37 -0700
Received: from gxk1 (gxk1.prod.google.com [10.202.11.1])
	by kpbe11.cbf.corp.google.com with ESMTP id o8K7BV0P009433
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 00:11:32 -0700
Received: by gxk1 with SMTP id 1so1651844gxk.26
        for <linux-mm@kvack.org>; Mon, 20 Sep 2010 00:11:31 -0700 (PDT)
Date: Mon, 20 Sep 2010 00:11:18 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] Document the new Anonymous field in smaps.
In-Reply-To: <201009171134.02771.knikanth@suse.de>
Message-ID: <alpine.LSU.2.00.1009200003150.4348@sister.anvils>
References: <AANLkTini3k1hK-9RM6io0mOf4VoDzGpbUEpiv=WHfhEW@mail.gmail.com> <201009161135.00129.knikanth@suse.de> <alpine.DEB.2.00.1009160940330.24798@tigran.mtv.corp.google.com> <201009171134.02771.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1106520754-1284966689=:4348"
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Matt Mackall <mpm@selenic.com>, Richard Guenther <rguenther@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1106520754-1284966689=:4348
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 17 Sep 2010, Nikanth Karthikesan wrote:
> Document the new Anonymous field in smaps.

Thanks for doing that, good effort, but your shifts between singular
and plural rather jarred on my ear, so I've rewritten it a little below.
Also added a sentence on "Swap"; but gave up when it came to KernelPageSize
and MMUPageSize, let someone else clarify those later.


[PATCH v3] Document the new Anonymous field in smaps.

From: Nikanth Karthikesan <knikanth@suse.de>

Document the new Anonymous field in smaps, and also the Swap field.
Explain what smaps means by shared and private, which differs from
MAP_SHARED and MAP_PRIVATE.

Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 Documentation/filesystems/proc.txt |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

--- a/Documentation/filesystems/proc.txt
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
-The first  of these lines shows  the same information  as is displayed for=
 the
-mapping in /proc/PID/maps.  The remaining lines show  the size of the mapp=
ing,
+The first of these lines shows the same information as is displayed for th=
e
+mapping in /proc/PID/maps. The remaining lines show the size of the mappin=
g,
 the amount of the mapping that is currently resident in RAM, the "proporti=
onal
 set size=E2=80=9D (divide each shared page by the number of processes shar=
ing it), the
 number of clean and dirty shared pages in the mapping, and the number of c=
lean
-and dirty private pages in the mapping.  The "Referenced" indicates the am=
ount
-of memory currently marked as referenced or accessed.
+and dirty private pages in the mapping. Note that even a page which is par=
t of
+a MAP_SHARED mapping, but has only a single pte mapped, i.e. is currently =
used
+by only one process, is accounted as private and not as shared. "Reference=
d"
+indicates the amount of memory currently marked as referenced or accessed.
+"Anonymous" shows the amount of memory that does not belong to any file. E=
ven
+a mapping associated with a file may contain anonymous pages: when MAP_PRI=
VATE
+and a page is modified, the file page is replaced by a private anonymous c=
opy.
+"Swap" shows how much would-be-anonymous memory is also used, but out on s=
wap.
=20
 This file is only present if the CONFIG_MMU kernel configuration option is
 enabled.
--8323584-1106520754-1284966689=:4348--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
