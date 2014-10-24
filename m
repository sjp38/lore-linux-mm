Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2836D6B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 06:18:48 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id l4so2267965lbv.26
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 03:18:47 -0700 (PDT)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [2001:4b98:dc2:45:216:3eff:febb:480d])
        by mx.google.com with ESMTPS id p6si6226000lap.91.2014.10.24.03.18.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 03:18:46 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Subject: [PATCH v2 0/4] Low/high memory CMA reservation fixes
Date: Fri, 24 Oct 2014 13:18:38 +0300
Message-Id: <1414145922-26042-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Weijie Yang <weijie.yang.kh@gmail.com>

Hello,

This patch set fixes an issue introduced by commits 95b0e655f914 ("ARM: mm:
don't limit default CMA region only to low memory") and f7426b983a6a ("mm:
cma: adjust address limit to avoid hitting low/high memory boundary")
resulting in reserved areas crossing the low/high memory boundary.

Patches 1/4 and 2/4 fix sides issues, with the bulk of the work in patch 3/4.
Patch 4/4 then fixes a printk issue that got me puzzled wondering why memory
reported under the lowmem limit was actually highmem.

This series fixes a v3.18-rc1 regression causing Renesas Koelsch boot
breakages when CMA is enabled.

Changes since v1:

- Use the cma count field to detect non-activated reservations
- Remove the redundant limit adjustment

Laurent Pinchart (4):
  mm: cma: Don't crash on allocation if CMA area can't be activated
  mm: cma: Always consider a 0 base address reservation as dynamic
  mm: cma: Ensure that reservations never cross the low/high mem
    boundary
  mm: cma: Use %pa to print physical addresses

 mm/cma.c | 68 +++++++++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 44 insertions(+), 24 deletions(-)

-- 
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
