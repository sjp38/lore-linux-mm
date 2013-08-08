Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id E24016B0033
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 01:05:31 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH part2 0/4] acpi: Trivial fix and improving for memory hotplug.
Date: Thu, 8 Aug 2013 13:03:55 +0800
Message-Id: <1375938239-18769-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

This patch-set does some trivial fix and improving in ACPI code
for memory hotplug.

Patch 1,3,4 have been acked.

Tang Chen (4):
  acpi: Print Hot-Pluggable Field in SRAT.
  earlycpio.c: Fix the confusing comment of find_cpio_data().
  acpi: Remove "continue" in macro INVALID_TABLE().
  acpi: Introduce acpi_verify_initrd() to check if a table is invalid.

 arch/x86/mm/srat.c |   11 ++++--
 drivers/acpi/osl.c |   84 +++++++++++++++++++++++++++++++++++++++------------
 lib/earlycpio.c    |   27 ++++++++--------
 3 files changed, 85 insertions(+), 37 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
