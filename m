Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D970C6B0035
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 23:38:00 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so2482120pac.18
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 20:38:00 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id pm6si1033267pac.140.2014.07.16.20.37.59
        for <linux-mm@kvack.org>;
        Wed, 16 Jul 2014 20:37:59 -0700 (PDT)
Date: Thu, 17 Jul 2014 11:37:12 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 181/478] mm/vmstat.c:1248:16: sparse: symbol
 'cpu_stat_off' was not declared. Should it be static?
Message-ID: <53c744e8.YPShDCfuB/HYtMKP%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_53c744e8.LJ/LM/I9CL4h5EIWUZwYF8d+eRRpjCYcQ5ScvQKg2YQgwsBD"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

This is a multi-part message in MIME format.

--=_53c744e8.LJ/LM/I9CL4h5EIWUZwYF8d+eRRpjCYcQ5ScvQKg2YQgwsBD
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   233caf2762158b2e2a7c03ba1d17e57a87f0670c
commit: 28ed3dd4a9b9f990a4131631ec2ff74233e2ebbc [181/478] vmstat: On demand vmstat workers V8
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/vmstat.c:1248:16: sparse: symbol 'cpu_stat_off' was not declared. Should it be static?

Please consider folding the attached diff :-)

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--=_53c744e8.LJ/LM/I9CL4h5EIWUZwYF8d+eRRpjCYcQ5ScvQKg2YQgwsBD
Content-Type: text/x-diff;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="make-it-static-28ed3dd4a9b9f990a4131631ec2ff74233e2ebbc.diff"

From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH mmotm] vmstat: cpu_stat_off can be static
TO: Christoph Lameter <cl@linux-foundation.org>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: linux-mm@kvack.org 
CC: linux-kernel@vger.kernel.org 

CC: Christoph Lameter <cl@linux-foundation.org>
CC: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 vmstat.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index ababac7..a3a5cce 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1245,7 +1245,7 @@ static const struct file_operations proc_vmstat_file_operations = {
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
 int sysctl_stat_interval __read_mostly = HZ;
-struct cpumask *cpu_stat_off;
+static struct cpumask *cpu_stat_off;
 
 static void vmstat_update(struct work_struct *w)
 {

--=_53c744e8.LJ/LM/I9CL4h5EIWUZwYF8d+eRRpjCYcQ5ScvQKg2YQgwsBD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
