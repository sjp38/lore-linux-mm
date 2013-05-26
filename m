Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id DB5B26B006E
	for <linux-mm@kvack.org>; Sun, 26 May 2013 01:58:57 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 26 May 2013 11:24:53 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id B1D751258056
	for <linux-mm@kvack.org>; Sun, 26 May 2013 11:30:51 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4Q5wjiV51052740
	for <linux-mm@kvack.org>; Sun, 26 May 2013 11:28:45 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4Q5woHt010921
	for <linux-mm@kvack.org>; Sun, 26 May 2013 15:58:50 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [patch v2 3/6] mm/memory_hotplug: Disable memory hotremove for 32bit
Date: Sun, 26 May 2013 13:58:38 +0800
Message-Id: <1369547921-24264-3-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1369547921-24264-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

As KOSAKI Motohiro mentioned, memory hotplug don't support 32bit since 
it was born, this patch disable memory hotremove when 32bit at compile 
time.

Suggested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index e742d06..ada9569 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -184,6 +184,7 @@ config MEMORY_HOTREMOVE
 	bool "Allow for memory hot remove"
 	select MEMORY_ISOLATION
 	select HAVE_BOOTMEM_INFO_NODE if X86_64
+	depends on 64BIT
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
