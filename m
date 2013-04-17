From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: fix build warning about
 kernel_physical_mapping_remove()
Date: Wed, 17 Apr 2013 15:22:14 +0800
Message-ID: <6111.39041507176$1366183558@news.gmane.org>
References: <1366182958-21892-1-git-send-email-wangyijing@huawei.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1USMkZ-0002a6-5f
	for glkm-linux-mm-2@m.gmane.org; Wed, 17 Apr 2013 09:25:51 +0200
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
Content-Disposition: inline
In-Reply-To: <1366182958-21892-1-git-send-email-wangyijing@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, jiang.liu@huawei.com, Yijing Wang <wangyijing@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

On Wed, Apr 17, 2013 at 03:15:58PM +0800, Yijing Wang wrote:
>If CONFIG_MEMORY_HOTREMOVE is not set, a build warning about
>"warning: =E2=80=98kernel_physical_mapping_remove=E2=80=99 defined but n=
ot used"
>report.
>

This has already been fixed by Tang Chen.=20
http://marc.info/?l=3Dlinux-mm&m=3D136614697618243&w=3D2

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
>@@ -1019,6 +1019,7 @@ void __ref vmemmap_free(struct page *memmap, unsig=
ned long nr_pages)
> 	remove_pagetable(start, end, false);
> }
>
>+#ifdef CONFIG_MEMORY_HOTREMOVE
> static void __meminit
> kernel_physical_mapping_remove(unsigned long start, unsigned long end)
> {
>@@ -1028,7 +1029,6 @@ kernel_physical_mapping_remove(unsigned long start=
, unsigned long end)
> 	remove_pagetable(start, end, true);
> }
>
>-#ifdef CONFIG_MEMORY_HOTREMOVE
> int __ref arch_remove_memory(u64 start, u64 size)
> {
> 	unsigned long start_pfn =3D start >> PAGE_SHIFT;
>--=20
>1.7.1
>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
