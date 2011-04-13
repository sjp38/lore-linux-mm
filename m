Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8FA94900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 22:20:32 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E74903EE0AE
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:20:28 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D05C445DE61
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:20:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BACE445DD74
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:20:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id ADB761DB803A
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:20:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 78DDA1DB802C
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:20:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/3] fremap: convert vm_flags to unsigned long long
In-Reply-To: <20110413112002.41E8.A69D9226@jp.fujitsu.com>
References: <20110413084047.41DD.A69D9226@jp.fujitsu.com> <20110413112002.41E8.A69D9226@jp.fujitsu.com>
Message-Id: <20110413112043.41EC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 13 Apr 2011 11:20:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

=46rom 17ef533fc09249b167f9ff3ec47d92e52c5cfeb3 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 13 Apr 2011 09:29:56 +0900
Subject: [PATCH 2/3] fremap: convert vm_flags to unsigned long long

Anyway, unsigned int is completely wrong type.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/fremap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/fremap.c b/mm/fremap.c
index ec520c7..354031e 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -224,7 +224,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start,=
 unsigned long, size,
 		/*
 		 * drop PG_Mlocked flag for over-mapped range
 		 */
-		unsigned int saved_flags =3D vma->vm_flags;
+		unsigned long long saved_flags =3D vma->vm_flags;
 		munlock_vma_pages_range(vma, start, start + size);
 		vma->vm_flags =3D saved_flags;
 	}
--=20
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
