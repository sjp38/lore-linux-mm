Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id EE6CE6B0081
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 12:36:46 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id c9so2331260qcz.15
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 09:36:46 -0700 (PDT)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id l4si5703118qat.125.2014.07.17.09.36.45
        for <linux-mm@kvack.org>;
        Thu, 17 Jul 2014 09:36:46 -0700 (PDT)
Date: Thu, 17 Jul 2014 11:36:43 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [mmotm:master 181/478] mm/vmstat.c:1248:16: sparse: symbol
 'cpu_stat_off' was not declared. Should it be static?
In-Reply-To: <53c744e8.YPShDCfuB/HYtMKP%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.11.1407171136260.18203@gentwo.org>
References: <53c744e8.YPShDCfuB/HYtMKP%fengguang.wu@intel.com>
Content-Type: MULTIPART/Mixed; BOUNDARY="=_53c744e8.LJ/LM/I9CL4h5EIWUZwYF8d+eRRpjCYcQ5ScvQKg2YQgwsBD"
Content-ID: <alpine.DEB.2.11.1407171136261.18203@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--=_53c744e8.LJ/LM/I9CL4h5EIWUZwYF8d+eRRpjCYcQ5ScvQKg2YQgwsBD
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.11.1407171136262.18203@gentwo.org>
Content-Disposition: INLINE

On Thu, 17 Jul 2014, kbuild test robot wrote:

> >> mm/vmstat.c:1248:16: sparse: symbol 'cpu_stat_off' was not declared. Should it be static?
>
> Please consider folding the attached diff :-)

Acked-by: Christoph Lameter <cl@linux.com>
--=_53c744e8.LJ/LM/I9CL4h5EIWUZwYF8d+eRRpjCYcQ5ScvQKg2YQgwsBD
Content-Type: TEXT/X-DIFF; CHARSET=us-ascii
Content-ID: <alpine.DEB.2.11.1407171136263.18203@gentwo.org>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=make-it-static-28ed3dd4a9b9f990a4131631ec2ff74233e2ebbc.diff

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
