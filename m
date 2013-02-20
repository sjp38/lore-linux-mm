Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 8DCB86B0007
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 06:01:42 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Bug fix PATCH 0/2] Make whatever node kernel resides in un-hotpluggable.
Date: Wed, 20 Feb 2013 19:00:54 +0800
Message-Id: <1361358056-1793-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

As mentioned by HPA before, when we are using movablemem_map=acpi, if all the
memory in SRAT is hotpluggable, then the kernel will have no memory to use, and
will fail to boot.

Before parsing SRAT, memblock has already reserved some memory in memblock.reserve,
which is used by the kernel, such as storing the kernel image. We are not able to
prevent the kernel from using these memory. So, these 2 patches make the node which
the kernel resides in un-hotpluggable.

patch1: Do not add the memory reserved by memblock into movablemenm_map.map[].
patch2: Do not add any other memory ranges in the same node into movablemenm_map.map[],
        so that make the node which the kernel resides in un-hotpluggable.

Tang Chen (2):
  acpi, movablemem_map: Exclude memblock.reserved ranges when parsing
    SRAT.
  acpi, movablemem_map: Make whatever nodes the kernel resides in
    un-hotpluggable.

 Documentation/kernel-parameters.txt |    6 ++++++
 arch/x86/mm/srat.c                  |   35 ++++++++++++++++++++++++++++++++++-
 include/linux/mm.h                  |    1 +
 3 files changed, 41 insertions(+), 1 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
