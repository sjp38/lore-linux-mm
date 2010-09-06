Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F2B7F6B0078
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 17:16:34 -0400 (EDT)
Date: Mon, 6 Sep 2010 14:09:05 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [RFCv5 0/9] CMA + VCMM integration
Message-ID: <20100906210905.GB5863@kroah.com>
References: <cover.1283749231.git.mina86@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1283749231.git.mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Pawel Osciak <p.osciak@samsung.com>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 06, 2010 at 08:33:50AM +0200, Michal Nazarewicz wrote:
> Hello everyone,
> 
> This patchset introduces a draft of a redesign of Zach Pfeffer's
> VCMM.

What is a VCMM?

What is a CMA?

> Not all of the functionality of the original VCMM has been
> ported into this patchset.  This is mostly meant as RFC.  Moreover,
> the code for VCMM implementation in this RFC has not been tested.

If you haven't even tested it, why should we review it?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
