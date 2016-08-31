From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: [PATCH] Update my e-mail address
Date: Wed, 31 Aug 2016 15:01:26 +0300
Message-ID: <1472644886-9933-1-git-send-email-vdavydov.dev@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

vdavydov@{parallels,virtuozzo}.com will bounce from now on.

Signed-off-by: Vladimir Davydov <vdavydov.dev@gmail.com>
---
 .mailmap    | 2 ++
 MAINTAINERS | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/.mailmap b/.mailmap
index b18912c5121e..de22daefd9da 100644
--- a/.mailmap
+++ b/.mailmap
@@ -159,6 +159,8 @@ Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
 Viresh Kumar <vireshk@kernel.org> <viresh.kumar@st.com>
 Viresh Kumar <vireshk@kernel.org> <viresh.linux@gmail.com>
 Viresh Kumar <vireshk@kernel.org> <viresh.kumar2@arm.com>
+Vladimir Davydov <vdavydov.dev@gmail.com> <vdavydov@virtuozzo.com>
+Vladimir Davydov <vdavydov.dev@gmail.com> <vdavydov@parallels.com>
 Takashi YOSHII <takashi.yoshii.zj@renesas.com>
 Yusuke Goda <goda.yusuke@renesas.com>
 Gustavo Padovan <gustavo@las.ic.unicamp.br>
diff --git a/MAINTAINERS b/MAINTAINERS
index d8e81b1dde30..46a7d3093a49 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3265,7 +3265,7 @@ F:	kernel/cpuset.c
 CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)
 M:	Johannes Weiner <hannes@cmpxchg.org>
 M:	Michal Hocko <mhocko@kernel.org>
-M:	Vladimir Davydov <vdavydov@virtuozzo.com>
+M:	Vladimir Davydov <vdavydov.dev@gmail.com>
 L:	cgroups@vger.kernel.org
 L:	linux-mm@kvack.org
 S:	Maintained
-- 
2.1.4
