Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 217A06001DA
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 01:51:25 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2G5pMP7018760
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Mar 2010 14:51:22 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D44F45DE54
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:51:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BE4D245DE59
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:51:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 809E9E18002
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:51:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E59A1DB8040
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:51:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/5] tmpfs: handle MPOL_LOCAL mount option properly
In-Reply-To: <20100316143406.4C45.A69D9226@jp.fujitsu.com>
References: <201003122353.o2CNrC56015250@imap1.linux-foundation.org> <20100316143406.4C45.A69D9226@jp.fujitsu.com>
Message-Id: <20100316145022.4C4E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Mar 2010 14:51:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, kiran@scalex86.org, cl@linux-foundation.org, hugh.dickins@tiscali.co.uk, lee.schermerhorn@hp.com, mel@csn.ul.ie, stable@kernel.org, linux-mm <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

commit 71fe804b6d5 (mempolicy: use struct mempolicy pointer in
shmem_sb_info) added mpol=local mount option. but its feature is
broken since it was born. because such code always return 1 (i.e.
mount failure).

This patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ravikiran Thirumalai <kiran@scalex86.org>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: <stable@kernel.org>
---
 mm/mempolicy.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 3f77062..5c197d5 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2212,6 +2212,7 @@ int mpol_parse_str(char *str, struct mempolicy **mpol, int no_context)
 		if (nodelist)
 			goto out;
 		mode = MPOL_PREFERRED;
+		err = 0;
 		break;
 	case MPOL_DEFAULT:
 		/*
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
