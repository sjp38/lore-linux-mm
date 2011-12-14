Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 83CE86B02DA
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 08:28:11 -0500 (EST)
Received: by ghrr18 with SMTP id r18so296393ghr.14
        for <linux-mm@kvack.org>; Wed, 14 Dec 2011 05:28:10 -0800 (PST)
Message-ID: <4EE8A461.2080406@gmail.com>
Date: Wed, 14 Dec 2011 21:28:01 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm/mempolicy.c: use enum value MPOL_REBIND_ONCE instead of
 0 in mpol_rebind_policy
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

We have enum definition in mempolicy.h: MPOL_REBIND_ONCE.
It should replace the magic number 0 for step comparison in
function mpol_rebind_policy.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/mempolicy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 9c51f9f..ecdaa8d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -390,7 +390,7 @@ static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask,
 {
 	if (!pol)
 		return;
-	if (!mpol_store_user_nodemask(pol) && step == 0 &&
+	if (!mpol_store_user_nodemask(pol) && step == MPOL_REBIND_ONCE &&
 	    nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
 		return;
 
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
