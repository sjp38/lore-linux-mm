Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id BC7F36B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 12:27:05 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id 10so2884606lbg.18
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:27:05 -0700 (PDT)
Received: from mail-la0-x231.google.com (mail-la0-x231.google.com. [2a00:1450:4010:c03::231])
        by mx.google.com with ESMTPS id a4si7728651lbm.77.2014.10.24.09.27.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 09:27:03 -0700 (PDT)
Received: by mail-la0-f49.google.com with SMTP id gf13so1643688lab.36
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:27:02 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 3/4] mm: cma: Ensure that reservations never cross the low/high mem boundary
In-Reply-To: <1414145922-26042-4-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
References: <1414145922-26042-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <1414145922-26042-4-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Date: Fri, 24 Oct 2014 18:26:58 +0200
Message-ID: <xa1toat13031.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Weijie Yang <weijie.yang.kh@gmail.com>

On Fri, Oct 24 2014, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com> wrote:
> Commit 95b0e655f914 ("ARM: mm: don't limit default CMA region only to
> low memory") extended CMA memory reservation to allow usage of high
> memory. It relied on commit f7426b983a6a ("mm: cma: adjust address limit
> to avoid hitting low/high memory boundary") to ensure that the reserved
> block never crossed the low/high memory boundary. While the
> implementation correctly lowered the limit, it failed to consider the
> case where the base..limit range crossed the low/high memory boundary
> with enough space on each side to reserve the requested size on either
> low or high memory.
>
> Rework the base and limit adjustment to fix the problem. The function
> now starts by rejecting the reservation altogether for fixed
> reservations that cross the boundary, tries to reserve from high memory
> first and then falls back to low memory.
>
> Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
