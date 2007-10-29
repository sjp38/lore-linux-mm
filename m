Date: Mon, 29 Oct 2007 11:20:22 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] vmstat: fix section mismatch warning
Message-Id: <20071029112022.96006aa6.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: christoph@lameter.com, akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Mark start_cpu_timer() as __cpuinit instead of __devinit.
Fixes this section warning:

WARNING: vmlinux.o(.text+0x60e53): Section mismatch: reference to .init.text:start_cpu_timer (between 'vmstat_cpuup_callback' and 'vmstat_show')

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/vmstat.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2624-rc1g4-v1.orig/mm/vmstat.c
+++ linux-2624-rc1g4-v1/mm/vmstat.c
@@ -803,7 +803,7 @@ static void vmstat_update(struct work_st
 		sysctl_stat_interval);
 }
 
-static void __devinit start_cpu_timer(int cpu)
+static void __cpuinit start_cpu_timer(int cpu)
 {
 	struct delayed_work *vmstat_work = &per_cpu(vmstat_work, cpu);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
