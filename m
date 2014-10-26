Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id E33936B0069
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 08:43:52 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id pn19so4548851lab.14
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 05:43:51 -0700 (PDT)
Received: from galahad.ideasonboard.com (galahad.ideasonboard.com. [2001:4b98:dc2:45:216:3eff:febb:480d])
        by mx.google.com with ESMTPS id k17si15329367lab.102.2014.10.26.05.43.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Oct 2014 05:43:50 -0700 (PDT)
From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH v2 3/4] mm: cma: Ensure that reservations never cross the low/high mem boundary
Date: Sun, 26 Oct 2014 14:43:52 +0200
Message-ID: <1436531.s0VJY8ZaKv@avalon>
In-Reply-To: <xa1toat13031.fsf@mina86.com>
References: <1414145922-26042-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <1414145922-26042-4-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <xa1toat13031.fsf@mina86.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Weijie Yang <weijie.yang.kh@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On Friday 24 October 2014 18:26:58 Michal Nazarewicz wrote:
> On Fri, Oct 24 2014, Laurent Pinchart wrote:
> > Commit 95b0e655f914 ("ARM: mm: don't limit default CMA region only to
> > low memory") extended CMA memory reservation to allow usage of high
> > memory. It relied on commit f7426b983a6a ("mm: cma: adjust address limit
> > to avoid hitting low/high memory boundary") to ensure that the reserved
> > block never crossed the low/high memory boundary. While the
> > implementation correctly lowered the limit, it failed to consider the
> > case where the base..limit range crossed the low/high memory boundary
> > with enough space on each side to reserve the requested size on either
> > low or high memory.
> > 
> > Rework the base and limit adjustment to fix the problem. The function
> > now starts by rejecting the reservation altogether for fixed
> > reservations that cross the boundary, tries to reserve from high memory
> > first and then falls back to low memory.
> > 
> > Signed-off-by: Laurent Pinchart
> > <laurent.pinchart+renesas@ideasonboard.com>
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>

Thank you. Can we get this series merged in v3.18-rc ?

-- 
Regards,

Laurent Pinchart

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
