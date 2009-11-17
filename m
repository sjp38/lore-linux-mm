Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C9DD16B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 02:32:30 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAH7WSEF004877
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 16:32:28 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E43B45DE55
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:32:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A29B45DE4E
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:32:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0455D1DB803C
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:32:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id ADE051DB8038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:32:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] Mark cifs mailing list as "moderated as non-subscribers"
In-Reply-To: <20091117162111.3DE8.A69D9226@jp.fujitsu.com>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com> <20091117162111.3DE8.A69D9226@jp.fujitsu.com>
Message-Id: <20091117162808.3DEE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 16:32:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Steve French <sfrench@samba.org>
List-ID: <linux-mm.kvack.org>


if non-subscribers post bug report to CIFS mailing list, they will get
following messages.

	Your mail to 'linux-cifs-client' with the subject

	    [PATCH x/x] cifs: xxxxxxxxxxxxx

	Is being held until the list moderator can review it for approval.

	The reason it is being held:

	    Post by non-member to a members-only list

	Either the message will get posted to the list, or you will receive
	notification of the moderator's decision.  If you would like to cancel
	this posting, please visit the following URL:

members-only list should be written as so in MAINTAINERS file.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 MAINTAINERS |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 81d68d5..5c44047 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1418,8 +1418,8 @@ F:	include/linux/coda*.h
 
 COMMON INTERNET FILE SYSTEM (CIFS)
 M:	Steve French <sfrench@samba.org>
-L:	linux-cifs-client@lists.samba.org
-L:	samba-technical@lists.samba.org
+L:	linux-cifs-client@lists.samba.org (moderated for non-subscribers)
+L:	samba-technical@lists.samba.org (moderated for non-subscribers)
 W:	http://linux-cifs.samba.org/
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.6.git
 S:	Supported
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
