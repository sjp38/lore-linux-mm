Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6AD19900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 01:11:48 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B4FDA3EE0AE
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:11:45 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C8A845DE54
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:11:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 84CC445DE51
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:11:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 759A51DB803E
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:11:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 410B41DB803B
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:11:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] Undef __compiletime_{warning,error} if __CHECKER__ is defined
In-Reply-To: <20110415140952.F7AE.A69D9226@jp.fujitsu.com>
References: <20110415121424.F7A6.A69D9226@jp.fujitsu.com> <20110415140952.F7AE.A69D9226@jp.fujitsu.com>
Message-Id: <20110415141141.F7B6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 15 Apr 2011 14:11:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

=46rom 4560a800c056714a7b5f9dc813460698717e6998 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 15 Apr 2011 13:58:07 +0900
Subject: [PATCH] Undef __compiletime_{warning,error} if __CHECKER__ is defi=
ned

sparse can't parse warning and error attribute. then they should
be hidden from sparse.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Arjan van de Ven <arjan@infradead.org>
---
 include/linux/compiler-gcc4.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/compiler-gcc4.h b/include/linux/compiler-gcc4.h
index 64b7c00..dfadc96 100644
--- a/include/linux/compiler-gcc4.h
+++ b/include/linux/compiler-gcc4.h
@@ -51,7 +51,7 @@
 #if __GNUC_MINOR__ > 0
 #define __compiletime_object_size(obj) __builtin_object_size(obj, 0)
 #endif
-#if __GNUC_MINOR__ >=3D 4
+#if __GNUC_MINOR__ >=3D 4 && !defined(__CHECKER__)
 #define __compiletime_warning(message) __attribute__((warning(message)))
 #define __compiletime_error(message) __attribute__((error(message)))
 #endif
--=20
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
