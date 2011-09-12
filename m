Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BB2F3900137
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 16:16:11 -0400 (EDT)
Date: Mon, 12 Sep 2011 16:16:06 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: system freezing with 3.0.4
Message-ID: <20110912201606.GA24927@infradead.org>
References: <4E69A496.9040707@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E69A496.9040707@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-scsi@vger.kernel.org

On Fri, Sep 09, 2011 at 07:31:02AM +0200, Stefan Priebe - Profihost AG wrote:
> Hi list,
> 
> here's an updated post of my one yesterday.
> 
> We've updated some systems from 2.6.32 to 3.0.4 vanilla kernel.
> Since then we're expecting freezes every now and then. All in memory
> apps are still working but nothing which reads or writes from or to
> disk (at least it seems like that).

What storage driver(s) do you use?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
