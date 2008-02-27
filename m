Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1R48WRT028200
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 15:08:32 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1R48JVr4595788
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 15:08:19 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1R48JlB029172
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 15:08:19 +1100
Date: Wed, 27 Feb 2008 09:32:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Add Balbir as the maintainer for memory resource controller
Message-ID: <20080227040246.GA27018@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, xemul@openvz.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi, Andrew,

As per your request I am updating the maintainers file and adding
myself as the maintainer for the memory resource controller. KAMEZAWA,
Pavel and many others have helped out the memory resource controller.
I would request them to add themsevles as maintainers if they are
interested in doing so.

Add Balbir Singh as the memory resource controller maintainer.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 MAINTAINERS |    7 +++++++
 1 file changed, 7 insertions(+)

diff -puN MAINTAINERS~add-balbir-as-memcontrol-maintainer MAINTAINERS
--- linux-2.6.25-rc3/MAINTAINERS~add-balbir-as-memcontrol-maintainer	2008-02-27 08:49:33.000000000 +0530
+++ linux-2.6.25-rc3-balbir/MAINTAINERS	2008-02-27 08:58:35.000000000 +0530
@@ -2620,6 +2620,13 @@ L:	linux-kernel@vger.kernel.org
 W:	http://www.linux-mm.org
 S:	Maintained
 
+MEMORY RESOURCE CONTROLLER
+P:	Balbir Singh
+M:	balbir@linux.vnet.ibm.com
+L:	linux-mm@kvack.org
+L:	linux-kernel@vger.kernel.org
+S:	Maintained
+
 MEI MN10300/AM33 PORT
 P:	David Howells
 M:	dhowells@redhat.com
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
