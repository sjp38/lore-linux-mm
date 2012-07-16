Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 3D6FF6B005A
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 03:30:55 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M7800FF6SVE3IL0@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 16 Jul 2012 16:30:53 +0900 (KST)
Received: from AMDC159 ([106.116.147.30])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M7800GCUSV5BCD0@mmp2.samsung.com> for linux-mm@kvack.org;
 Mon, 16 Jul 2012 16:30:53 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
References: <1341824623-7472-1-git-send-email-prathyush.k@samsung.com>
In-reply-to: <1341824623-7472-1-git-send-email-prathyush.k@samsung.com>
Subject: RE: [PATCH v2] ARM: dma-mapping: modify condition check while freeing
 pages
Date: Mon, 16 Jul 2012 09:30:40 +0200
Message-id: <06fe01cd6324$e9767740$bc6365c0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Content-language: pl
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Prathyush K' <prathyush.k@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org

Hello,

On Monday, July 09, 2012 11:04 AM Prathyush K wrote:

> WARNING: at mm/vmalloc.c:1471 __iommu_free_buffer+0xcc/0xd0()
> Trying to vfree() nonexistent vm area (ef095000)
> Modules linked in:
> [<c0015a18>] (unwind_backtrace+0x0/0xfc) from [<c0025a94>] (warn_slowpath_common+0x54/0x64)
> [<c0025a94>] (warn_slowpath_common+0x54/0x64) from [<c0025b38>] (warn_slowpath_fmt+0x30/0x40)
> [<c0025b38>] (warn_slowpath_fmt+0x30/0x40) from [<c0016de0>] (__iommu_free_buffer+0xcc/0xd0)
> [<c0016de0>] (__iommu_free_buffer+0xcc/0xd0) from [<c0229a5c>]
> (exynos_drm_free_buf+0xe4/0x138)
> [<c0229a5c>] (exynos_drm_free_buf+0xe4/0x138) from [<c022b358>]
> (exynos_drm_gem_destroy+0x80/0xfc)
> [<c022b358>] (exynos_drm_gem_destroy+0x80/0xfc) from [<c0211230>]
> (drm_gem_object_free+0x28/0x34)
> [<c0211230>] (drm_gem_object_free+0x28/0x34) from [<c0211bd0>]
> (drm_gem_object_release_handle+0xcc/0xd8)
> [<c0211bd0>] (drm_gem_object_release_handle+0xcc/0xd8) from [<c01abe10>]
> (idr_for_each+0x74/0xb8)
> [<c01abe10>] (idr_for_each+0x74/0xb8) from [<c02114e4>] (drm_gem_release+0x1c/0x30)
> [<c02114e4>] (drm_gem_release+0x1c/0x30) from [<c0210ae8>] (drm_release+0x608/0x694)
> [<c0210ae8>] (drm_release+0x608/0x694) from [<c00b75a0>] (fput+0xb8/0x228)
> [<c00b75a0>] (fput+0xb8/0x228) from [<c00b40c4>] (filp_close+0x64/0x84)
> [<c00b40c4>] (filp_close+0x64/0x84) from [<c0029d54>] (put_files_struct+0xe8/0x104)
> [<c0029d54>] (put_files_struct+0xe8/0x104) from [<c002b930>] (do_exit+0x608/0x774)
> [<c002b930>] (do_exit+0x608/0x774) from [<c002bae4>] (do_group_exit+0x48/0xb4)
> [<c002bae4>] (do_group_exit+0x48/0xb4) from [<c002bb60>] (sys_exit_group+0x10/0x18)
> [<c002bb60>] (sys_exit_group+0x10/0x18) from [<c000ee80>] (ret_fast_syscall+0x0/0x30)
> 
> This patch modifies the condition while freeing to match the condition
> used while allocation. This fixes the above warning which arises when
> array size is equal to PAGE_SIZE where allocation is done using kzalloc
> but free is done using vfree.
> 
> Signed-off-by: Prathyush K <prathyush.k@samsung.com>

I've applied it to my fixes branch. Thanks for spotting the issue!

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
