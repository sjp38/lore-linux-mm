Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5229F6B004A
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 06:55:56 -0400 (EDT)
Date: Mon, 11 Jul 2011 03:55:53 -0700
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: writeback tree status
Message-ID: <20110711105553.GA6373@localhost>
References: <20110711104207.GA20317@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110711104207.GA20317@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

Hi Christoph,

On Mon, Jul 11, 2011 at 06:42:07PM +0800, Christoph Hellwig wrote:
> Hi Wu,
> 
> what is the state of the writeback updates for Linux 3.1?  There's
> still a lot of changes in your fs-writeback branch, but not in the
> next branch yet.  I know some are still under discussion, but it would
> be good to get everything destined for Linux 3.1 into linux-next ASAP
> so that it will get some testing.

Big sorry.. I just merged the fs-writeback patches into the branch for
linux-next. It seemed that I was a bit too nervous to push patches into
linux-next. I've been testing them locally, so far, so good. Hope the
linux-next push won't cause too much trouble for the wider testers.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
