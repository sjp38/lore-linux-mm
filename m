From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH] oom_kill: remove unused parameter in badness()
Date: Tue, 08 Apr 2008 15:54:55 +0800
Message-ID: <47FB24CF.40704@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753396AbYDHH5G@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-Id: linux-mm.kvack.org

In commit 4c4a22148909e4c003562ea7ffe0a06e26919e3c, we moved the
memcontroller-related code from badness() to select_bad_process(),
so the parameter 'mem' in badness() is unused now.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 mm/oom_kill.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f255eda..8be1baf 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -53,8 +53,7 @@ static DEFINE_SPINLOCK(zone_scan_mutex);
  *    of least surprise ... (be careful when you change it)
  */
 
-unsigned long badness(struct task_struct *p, unsigned long uptime,
-			struct mem_cgroup *mem)
+unsigned long badness(struct task_struct *p, unsigned long uptime)
 {
 	unsigned long points, cpu_time, run_time, s;
 	struct mm_struct *mm;
@@ -254,7 +253,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
 		if (p->oomkilladj == OOM_DISABLE)
 			continue;
 
-		points = badness(p, uptime.tv_sec, mem);
+		points = badness(p, uptime.tv_sec);
 		if (points > *ppoints || !chosen) {
 			chosen = p;
 			*ppoints = points;
-- 
1.5.4.rc3
