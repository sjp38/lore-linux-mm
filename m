Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A3998900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 22:22:05 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 763883EE0C0
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:22:02 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5726345DE9D
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:22:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 376B545DE94
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:22:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AB1DE08004
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:22:02 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E4A7FE18004
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:22:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/3] procfs: convert vm_flags to unsigned long long
In-Reply-To: <20110413112002.41E8.A69D9226@jp.fujitsu.com>
References: <20110413084047.41DD.A69D9226@jp.fujitsu.com> <20110413112002.41E8.A69D9226@jp.fujitsu.com>
Message-Id: <20110413112120.41F0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 13 Apr 2011 11:21:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

=46rom d8bbb29c55e449a8f7e87e2b6ef529b1162aeba0 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 13 Apr 2011 09:39:13 +0900
Subject: [PATCH 3/3] procfs: convert vm_flags to unsigned long long

int is crazy mistake. ;-)

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/proc/task_mmu.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 8caf687..51b9d98 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -211,7 +211,7 @@ static void show_map_vma(struct seq_file *m, struct vm_=
area_struct *vma)
 {
 	struct mm_struct *mm =3D vma->vm_mm;
 	struct file *file =3D vma->vm_file;
-	int flags =3D vma->vm_flags;
+	unsigned long long vm_flags =3D vma->vm_flags;
 	unsigned long ino =3D 0;
 	unsigned long long pgoff =3D 0;
 	unsigned long start;
@@ -234,10 +234,10 @@ static void show_map_vma(struct seq_file *m, struct v=
m_area_struct *vma)
 	seq_printf(m, "%08lx-%08lx %c%c%c%c %08llx %02x:%02x %lu %n",
 			start,
 			vma->vm_end,
-			flags & VM_READ ? 'r' : '-',
-			flags & VM_WRITE ? 'w' : '-',
-			flags & VM_EXEC ? 'x' : '-',
-			flags & VM_MAYSHARE ? 's' : 'p',
+			vm_flags & VM_READ ? 'r' : '-',
+			vm_flags & VM_WRITE ? 'w' : '-',
+			vm_flags & VM_EXEC ? 'x' : '-',
+			vm_flags & VM_MAYSHARE ? 's' : 'p',
 			pgoff,
 			MAJOR(dev), MINOR(dev), ino, &len);
=20
--=20
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
