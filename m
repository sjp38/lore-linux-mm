Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C73B16B006E
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 06:24:16 -0500 (EST)
Date: Mon, 21 Nov 2011 19:24:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/8] block: limit default readahead size for small
 devices
Message-ID: <20111121112409.GA8895@localhost>
References: <20111121091819.394895091@intel.com>
 <20111121093846.121502745@intel.com>
 <20111121100004.GB5084@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111121100004.GB5084@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "Li, Shaohua" <shaohua.li@intel.com>, Clemens Ladisch <clemens@ladisch.de>, Jens Axboe <jens.axboe@oracle.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

On Mon, Nov 21, 2011 at 06:00:04PM +0800, Christoph Hellwig wrote:
> On Mon, Nov 21, 2011 at 05:18:20PM +0800, Wu Fengguang wrote:
> > This looks reasonable: smaller device tend to be slower (USB sticks as
> > well as micro/mobile/old hard disks).
> > 
> > Given that the non-rotational attribute is not always reported, we can
> > take disk size as a max readahead size hint. This patch uses a formula
> > that generates the following concrete limits:
> 
> Given that you mentioned the rotational flag and device size in this
> mail, as well as benchmarking with an intel SSD  -  did you measure
> how useful large read ahead sizes still are with highend Flash device
> that have extremly high read IOP rates?

I don't know -- I don't have access to such highend devices.

However the patch changelog has the simple test script. It would be
high appreciated if someone can help collect the data :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
