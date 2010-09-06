Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5916B007B
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 17:16:38 -0400 (EDT)
Date: Mon, 6 Sep 2010 14:10:54 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [RFCv5 8/9] mm: vcm: Sample driver added
Message-ID: <20100906211054.GC5863@kroah.com>
References: <cover.1283749231.git.mina86@mina86.com> <262a5a5019c1f1a44d5793f7e69776e56f27af06.1283749231.git.mina86@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <262a5a5019c1f1a44d5793f7e69776e56f27af06.1283749231.git.mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Pawel Osciak <p.osciak@samsung.com>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 06, 2010 at 08:33:58AM +0200, Michal Nazarewicz wrote:
> --- /dev/null
> +++ b/include/linux/vcm-sample.h

Don't put "sample" code in include/linux/ please.  That's just
cluttering up the place, don't you think?  Especially as no one else
needs the file there...

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
