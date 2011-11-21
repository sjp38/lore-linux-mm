Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 728E46B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 07:47:19 -0500 (EST)
Date: Mon, 21 Nov 2011 13:47:15 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/8] block: limit default readahead size for small devices
Message-ID: <20111121124715.GD24062@one.firstfloor.org>
References: <20111121091819.394895091@intel.com> <20111121093846.121502745@intel.com> <20111121100004.GB5084@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111121100004.GB5084@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Li Shaohua <shaohua.li@intel.com>, Clemens Ladisch <clemens@ladisch.de>, Jens Axboe <jens.axboe@oracle.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

On Mon, Nov 21, 2011 at 05:00:04AM -0500, Christoph Hellwig wrote:
> On Mon, Nov 21, 2011 at 05:18:20PM +0800, Wu Fengguang wrote:
> > Given that the non-rotational attribute is not always reported, we can
> > take disk size as a max readahead size hint. This patch uses a formula
> > that generates the following concrete limits:
> 
> Given that you mentioned the rotational flag and device size in this
> mail, as well as benchmarking with an intel SSD  -  did you measure
> how useful large read ahead sizes still are with highend Flash device
> that have extremly high read IOP rates?

The more the IOPs the larger the "window" you need to keep everything
going I suspect.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
