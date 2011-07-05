Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6A58990012A
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 08:07:52 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv11 0/8] Contiguous Memory Allocator
Date: Tue, 5 Jul 2011 14:07:17 +0200
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <201107051407.17249.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Tuesday 05 July 2011, Marek Szyprowski wrote:
> This is yet another round of Contiguous Memory Allocator patches. I hope
> that I've managed to resolve all the items discussed during the Memory
> Management summit at Linaro Meeting in Budapest and pointed later on
> mailing lists. The goal is to integrate it as tight as possible with
> other kernel subsystems (like memory management and dma-mapping) and
> finally merge to mainline.

You have certainly addressed all of my concerns, this looks really good now!

Andrew, can you add this to your -mm tree? What's your opinion on the
current state, do you think this is ready for merging in 3.1 or would
you want to have more reviews from core memory management people?

My reviews were mostly on the driver and platform API side, and I think
we're fine there now, but I don't really understand the impacts this has
in mm.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
