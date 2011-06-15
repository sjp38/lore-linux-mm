Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 18B456B004A
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 07:53:25 -0400 (EDT)
Received: by vws4 with SMTP id 4so330910vws.14
        for <linux-mm@kvack.org>; Wed, 15 Jun 2011 04:53:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201106142030.07549.arnd@arndb.de>
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
	<201106141803.00876.arnd@arndb.de>
	<op.vw2r3xrj3l0zgt@mnazarewicz-glaptop>
	<201106142030.07549.arnd@arndb.de>
Date: Wed, 15 Jun 2011 13:53:22 +0200
Message-ID: <BANLkTi=XTJuF4np7+rYHzJqWK20OxMrBsw@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 08/10] mm: cma: Contiguous Memory
 Allocator added
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Michal Nazarewicz <mina86@mina86.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Jesse Barker <jesse.barker@linaro.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Tue, Jun 14, 2011 at 20:30, Arnd Bergmann <arnd@arndb.de> wrote:
> On Tuesday 14 June 2011 18:58:35 Michal Nazarewicz wrote:
>> Ah yes, I forgot that separate regions for different purposes could
>> decrease fragmentation.
>
> That is indeed a good point, but having a good allocator algorithm
> could also solve this. I don't know too much about these allocation
> algorithms, but there are probably multiple working approaches to this.

imo no allocator algorithm is gonna help if you have comparably large,
variable-sized contiguous allocations out of a restricted address range.
It might work well enough if there are only a few sizes and/or there's
decent headroom. But for really generic workloads this would require
sync objects and eviction callbacks (i.e. what Thomas Hellstrom pushed
with ttm).

So if this is only a requirement on very few platforms and can be
cheaply fixed with multiple cma allocation areas (heck, we have
slabs for the same reasons in the kernel), it might be a sensible
compromise.
-Daniel
-- 
Daniel Vetter
daniel.vetter@ffwll.ch - +41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
