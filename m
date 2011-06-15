Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 219B16B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 07:20:52 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-mm-sig] [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
Date: Wed, 15 Jun 2011 13:20:42 +0200
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com> <201106142242.25157.arnd@arndb.de> <op.vw31uxxl3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <op.vw31uxxl3l0zgt@mnazarewicz-glaptop>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201106151320.42182.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Zach Pfeffer <zach.pfeffer@linaro.org>, Daniel Stone <daniels@collabora.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Jesse Barker <jesse.barker@linaro.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Wednesday 15 June 2011, Michal Nazarewicz wrote:
> On Tue, 14 Jun 2011 22:42:24 +0200, Arnd Bergmann <arnd@arndb.de> wrote:
> > * We still need to solve the same problem in case of IOMMU mappings
> >   at some point, even if today's hardware doesn't have this combination.
> >   It would be good to use the same solution for both.
> 
> I don't think I follow.  What does IOMMU has to do with CMA?

The point is that on the higher level device drivers, we want to
hide the presence of CMA and/or IOMMU behind the dma mapping API,
but the device drivers do need to know about the bank properties.

If we want to solve the problem of allocating per-bank memory inside
of CMA, we also need to solve it inside of the IOMMU code, using
the same device driver interface.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
