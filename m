Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 345726B0089
	for <linux-mm@kvack.org>; Sat, 11 Dec 2010 04:40:19 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [RFC,0/7] mm: vcm: The Virtual Memory Manager for multiple IOMMUs
Date: Sat, 11 Dec 2010 18:21:12 +0900
Message-Id: <1292059279-10026-1-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@xenotime.net>, Michal Nazarewicz <m.nazarewicz@samsung.com>, InKi Dae <inki.dae@samsung.com>
List-ID: <linux-mm.kvack.org>

Hello,

The VCM is a framework to deal with multiple IOMMUs in a system 
with intuitive and abstract objects
These patches are the bugfix and enhanced version of previous RFC by Michal Nazarewicz.
(https://patchwork.kernel.org/patch/157451/)

It is introduced by Zach Pfeffer and implemented by Michal Nazarewicz.
These patches include entirely new implementation of VCM than the one submitted by Zach Pfeffer.

The prerequisites of these patches are the followings:
https://patchwork.kernel.org/patch/340281/
https://patchwork.kernel.org/patch/340121/
https://patchwork.kernel.org/patch/340321/

And the prerequisites of "[RFC,6/7] mm: vcm: vcm-cma: VCM CMA driver added" are
all 13 patches of RFCv6 submitted by Michal Nazarewicz
(https://patchwork.kernel.org/project/LKML/list/?submitter=2150)
The VCM also works correctly without "[RFC,6/7] mm: vcm: vcm-cma: VCM CMA driver added"

The last patch, "[RFC,7/7] mm: vcm: Sample driver added" is not the one to be submitted
but is an example to show how to use the VCM.

The VCM provides generic interfaces and objects to deal with IOMMUs in various architectures
especially the ones that embed multiple IOMMUs including GART.

Patch list:
[RFC,1/7] mm: vcm: Virtual Contiguous Memory framework added
[RFC,2/7] mm: vcm: physical memory allocator added
[RFC,3/7] mm: vcm: VCM VMM driver added
[RFC,4/7] mm: vcm: VCM MMU wrapper added
[RFC,5/7] mm: vcm: VCM One-to-One wrapper added
[RFC,6/7] mm: vcm: vcm-cma: VCM CMA driver added
[RFC,7/7] mm: vcm: Sample driver added

Summary:
Documentation/00-INDEX                      |    2 +
Documentation/virtual-contiguous-memory.txt |  893 ++++++++++++++++++++++++
include/linux/vcm-cma.h                     |   38 +
include/linux/vcm-drv.h                     |  326 +++++++++
include/linux/vcm-sample.h                  |   30 +
include/linux/vcm.h                         |  288 ++++++++
mm/Kconfig                                  |   72 ++
mm/Makefile                                 |    3 +
mm/vcm-cma.c                                |  103 +++
mm/vcm-sample.c                             |  119 ++++
mm/vcm.c                                    |  970 +++++++++++++++++++++++++++
11 files changed, 2844 insertions(+), 0 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
