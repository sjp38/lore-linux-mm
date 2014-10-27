Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6341A6B006C
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 03:43:31 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so5116493pde.22
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 00:43:31 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ia9si9886902pbc.55.2014.10.27.00.43.28
        for <linux-mm@kvack.org>;
        Mon, 27 Oct 2014 00:43:30 -0700 (PDT)
Date: Mon, 27 Oct 2014 16:44:42 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 3/4] mm: cma: Ensure that reservations never cross the
 low/high mem boundary
Message-ID: <20141027074442.GD23379@js1304-P5Q-DELUXE>
References: <1414145922-26042-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
 <1414145922-26042-4-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
 <xa1toat13031.fsf@mina86.com>
 <1436531.s0VJY8ZaKv@avalon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436531.s0VJY8ZaKv@avalon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Weijie Yang <weijie.yang.kh@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Oct 26, 2014 at 02:43:52PM +0200, Laurent Pinchart wrote:
> On Friday 24 October 2014 18:26:58 Michal Nazarewicz wrote:
> > On Fri, Oct 24 2014, Laurent Pinchart wrote:
> > > Commit 95b0e655f914 ("ARM: mm: don't limit default CMA region only to
> > > low memory") extended CMA memory reservation to allow usage of high
> > > memory. It relied on commit f7426b983a6a ("mm: cma: adjust address limit
> > > to avoid hitting low/high memory boundary") to ensure that the reserved
> > > block never crossed the low/high memory boundary. While the
> > > implementation correctly lowered the limit, it failed to consider the
> > > case where the base..limit range crossed the low/high memory boundary
> > > with enough space on each side to reserve the requested size on either
> > > low or high memory.
> > > 
> > > Rework the base and limit adjustment to fix the problem. The function
> > > now starts by rejecting the reservation altogether for fixed
> > > reservations that cross the boundary, tries to reserve from high memory
> > > first and then falls back to low memory.
> > > 
> > > Signed-off-by: Laurent Pinchart
> > > <laurent.pinchart+renesas@ideasonboard.com>
> > 
> > Acked-by: Michal Nazarewicz <mina86@mina86.com>
> 
> Thank you. Can we get this series merged in v3.18-rc ?


Hello,

You'd better to resend whole series to Andrew.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
