Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 0C4726B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 08:02:23 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Bug fix PATCH 0/2] Bug fix for movablemem_map boot option.
Date: Tue, 19 Feb 2013 21:01:42 +0800
Message-Id: <1361278904-8690-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Two bug fix patches for movablemem_map boot option.

root (2):
  acpi, movablemem_map: Do not zero numa_meminfo in numa_init().
  acpi, movablemem_map: Set numa_nodes_hotplug nodemask when using SRAT
    info.

 arch/x86/mm/numa.c |    6 ++++--
 arch/x86/mm/srat.c |    6 ++++++
 2 files changed, 10 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
