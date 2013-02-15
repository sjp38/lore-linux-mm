Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 08A016B0011
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 07:38:33 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] ia64: rename cache_show to topology_cache_show
Date: Fri, 15 Feb 2013 13:38:24 +0100
Message-Id: <1360931904-5720-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <511e236a.o0ibbB2U8xMoURgd%fengguang.wu@intel.com>
References: <511e236a.o0ibbB2U8xMoURgd%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Glauber Costa <glommer@parallels.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

Fenguang Wu has reported the following compile time issue
arch/ia64/kernel/topology.c:278:16: error: conflicting types for 'cache_show'
include/linux/slab.h:224:5: note: previous declaration of 'cache_show' was here

which has been introduced by 749c5415 (memcg: aggregate memcg cache
values in slabinfo). Let's rename ia64 local function to prevent from
the name conflict.

Reported-by: Fenguang Wu <fengguang.wu@intel.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 arch/ia64/kernel/topology.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index c64460b..d9e2152 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -275,7 +275,8 @@ static struct attribute * cache_default_attrs[] = {
 #define to_object(k) container_of(k, struct cache_info, kobj)
 #define to_attr(a) container_of(a, struct cache_attr, attr)
 
-static ssize_t cache_show(struct kobject * kobj, struct attribute * attr, char * buf)
+static ssize_t topology_cache_show(struct kobject * kobj,
+		struct attribute * attr, char * buf)
 {
 	struct cache_attr *fattr = to_attr(attr);
 	struct cache_info *this_leaf = to_object(kobj);
@@ -286,7 +287,7 @@ static ssize_t cache_show(struct kobject * kobj, struct attribute * attr, char *
 }
 
 static const struct sysfs_ops cache_sysfs_ops = {
-	.show   = cache_show
+	.show   = topology_cache_show
 };
 
 static struct kobj_type cache_ktype = {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
