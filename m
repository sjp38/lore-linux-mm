Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 99D776B00C6
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 17:07:10 -0500 (EST)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 7 Jan 2011 17:04:58 -0500
Subject: [RFC][PATCH 1/2] Add explanation about min_free_kbytes to clarify
 its effect
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A297@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A295@USINDEVS02.corp.hds.com>
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A295@USINDEVS02.corp.hds.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>
List-ID: <linux-mm.kvack.org>

Document that changing min_free_kbytes affects not only watermark[min]
but also watermark[low,high].

Signed-off-by: Satoru Moriya <satoru.moriya@hds.com>
---
 Documentation/sysctl/vm.txt |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 30289fa..e10b279 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -349,7 +349,8 @@ min_free_kbytes:
=20
 This is used to force the Linux VM to keep a minimum number
 of kilobytes free.  The VM uses this number to compute a
-watermark[WMARK_MIN] value for each lowmem zone in the system.
+watermark[WMARK_MIN] for each lowmem zone and
+watermark[WMARK_LOW/WMARK_HIGH] for each zone in the system.
 Each lowmem zone gets a number of reserved free pages based
 proportionally on its size.
=20
--=20
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
