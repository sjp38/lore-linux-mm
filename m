Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id B7D226B0092
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:33:56 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id s18so958158lam.23
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:33:56 -0700 (PDT)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [2001:4b98:dc2:45:216:3eff:febb:480d])
        by mx.google.com with ESMTPS id nu7si2938678lbb.18.2014.10.23.07.33.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 07:33:54 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Subject: [PATCH 0/4] Low/high memory CMA reservation fixes
Date: Thu, 23 Oct 2014 17:33:44 +0300
Message-Id: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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

Laurent Pinchart (4):
  mm: cma: Don't crash on allocation if CMA area can't be activated
  mm: cma: Always consider a 0 base address reservation as dynamic
  mm: cma: Ensure that reservations never cross the low/high mem
    boundary
  mm: cma: Use %pa to print physical addresses

 mm/cma.c | 93 +++++++++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 60 insertions(+), 33 deletions(-)

-- 
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
