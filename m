Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 8E9406B00EC
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 07:42:18 -0500 (EST)
Message-ID: <4F475B6F.4060306@oracle.com>
Date: Fri, 24 Feb 2012 17:42:07 +0800
From: Jeff Liu <jeff.liu@oracle.com>
Reply-To: jeff.liu@oracle.com
MIME-Version: 1.0
Subject: [PATCH] Remove unnecessary 'break' at mem_cgroup_read() for invalid
 MEMFILE_TYPE.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org

Hello,

The 'break' is unnecessary at mem_cgroup_read() routine if the MEMFILE_TYPE is invalid IMHO. 


Signed-off-by: Jie Liu <jeff.liu@oracle.com>

---
 mm/memcontrol.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6aff93c..105972c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3886,7 +3886,6 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 		break;
 	default:
 		BUG();
-		break;
 	}
 	return val;
 }
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
