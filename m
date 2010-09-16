Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C40BE6B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 02:02:12 -0400 (EDT)
From: Nikanth Karthikesan <knikanth@suse.de>
Subject: [PATCH] Document the new Anonymous field in smaps.
Date: Thu, 16 Sep 2010 11:34:59 +0530
References: <AANLkTini3k1hK-9RM6io0mOf4VoDzGpbUEpiv=WHfhEW@mail.gmail.com> <201009160856.25923.knikanth@suse.de> <20100916125147.CA08.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100916125147.CA08.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201009161135.00129.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Matt Mackall <mpm@selenic.com>, Richard Guenther <rguenther@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Sorry, I missed to add documentation, when I sent the patch. This depends on
the patch titled, "[PATCH] Export amount of anonymous memory in a mapping v=
ia
smaps".

Thanks
Nikanth


Document the new Anonymous field in smaps.

Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

=2D--

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems=
/proc.txt
index a6aca87..75c7368 100644
=2D-- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -370,6 +370,7 @@ Shared_Dirty:          0 kB
 Private_Clean:         0 kB
 Private_Dirty:         0 kB
 Referenced:          892 kB
+Anonymous:             0 kB
 Swap:                  0 kB
 KernelPageSize:        4 kB
 MMUPageSize:           4 kB
@@ -380,7 +381,10 @@ the amount of the mapping that is currently resident i=
n RAM, the "proportional
 set size=E2=80=9D (divide each shared page by the number of processes shar=
ing it), the
 number of clean and dirty shared pages in the mapping, and the number of c=
lean
 and dirty private pages in the mapping.  The "Referenced" indicates the am=
ount
=2Dof memory currently marked as referenced or accessed.
+of memory currently marked as referenced or accessed. The "Anonymous" shows
+the amount of mapping that is not associated with a file. Even the private
+pages in a mapping associated with a file, would become anonymous, when th=
ey
+are modified.
=20
 This file is only present if the CONFIG_MMU kernel configuration option is
 enabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
