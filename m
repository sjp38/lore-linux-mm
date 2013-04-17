Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 2D4B56B0072
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 03:25:48 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 17 Apr 2013 12:51:04 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 4A1021258055
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 12:57:10 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3H7PWRY7733732
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 12:55:33 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3H7PcXj026884
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 17:25:38 +1000
Date: Wed, 17 Apr 2013 15:22:14 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: fix build warning about
 kernel_physical_mapping_remove()
Message-ID: <20130417072214.GA25283@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1366182958-21892-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1366182958-21892-1-git-send-email-wangyijing@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yijing Wang <wangyijing@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

On Wed, Apr 17, 2013 at 03:15:58PM +0800, Yijing Wang wrote:
>If CONFIG_MEMORY_HOTREMOVE is not set, a build warning about
>"warning: a??kernel_physical_mapping_removea?? defined but not used"
>report.
>

This has already been fixed by Tang Chen. 
http://marc.info/?l=linux-mm&m=136614697618243&w=2

>Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>Cc: Tang Chen <tangchen@cn.fujitsu.com>
>Cc: Wen Congyang <wency@cn.fujitsu.com>
>---
> arch/x86/mm/init_64.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
>index 474e28f..dafdeb2 100644
>--- a/arch/x86/mm/init_64.c
>+++ b/arch/x86/mm/init_64.c
>@@ -1019,6 +1019,7 @@ void __ref vmemmap_free(struct page *memmap, unsigned long nr_pages)
> 	remove_pagetable(start, end, false);
> }
>
>+#ifdef CONFIG_MEMORY_HOTREMOVE
> static void __meminit
> kernel_physical_mapping_remove(unsigned long start, unsigned long end)
> {
>@@ -1028,7 +1029,6 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
> 	remove_pagetable(start, end, true);
> }
>
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> int __ref arch_remove_memory(u64 start, u64 size)
> {
> 	unsigned long start_pfn = start >> PAGE_SHIFT;
>-- 
>1.7.1
>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
