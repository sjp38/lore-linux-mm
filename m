Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7DD436B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 08:38:43 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by bombadil.infradead.org with esmtps (Exim 4.76 #1 (Red Hat Linux))
	id 1QOqsi-0005ft-HT
	for linux-mm@kvack.org; Tue, 24 May 2011 12:38:40 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1QOqsh-0007js-Kj
	for linux-mm@kvack.org; Tue, 24 May 2011 12:38:39 +0000
Subject: Re: [PATCH 4/4] writeback: reduce per-bdi dirty threshold ramp up
 time
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1306239869.2497.50.camel@laptop>
References: <20110413220444.GF4648@quack.suse.cz>
	 <20110413233122.GA6097@localhost> <20110413235211.GN31057@dastard>
	 <20110414002301.GA9826@localhost> <20110414151424.GA367@localhost>
	 <20110414181609.GH5054@quack.suse.cz> <20110415034300.GA23430@localhost>
	 <20110415143711.GA17181@localhost> <20110415221314.GE5432@quack.suse.cz>
	 <1302942809.2388.254.camel@twins>  <20110418145929.GH5557@quack.suse.cz>
	 <1306239869.2497.50.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 24 May 2011 14:41:58 +0200
Message-ID: <1306240918.2497.53.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Richard Kennedy <richard@rsk.demon.co.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Tue, 2011-05-24 at 14:24 +0200, Peter Zijlstra wrote:
> Again, if we then measure t in the same events as x, such that:
> 
>  t = \Sum_i x_i

> However, if you start measuring t differently that breaks, and the
> result is no longer normalized and thus not suitable as a proportion.

Ah, I made a mistake there, your proposal would keep the above relation
true, but the discrete periods t_i wouldn't be uniform.

So disregard the non normalized criticism.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
