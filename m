Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 84A0E6B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 12:57:47 -0500 (EST)
Date: Tue, 29 Nov 2011 18:57:43 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/9] readahead: record readahead patterns
Message-ID: <20111129175743.GP24062@one.firstfloor.org>
References: <20111129130900.628549879@intel.com> <20111129131456.278516066@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111129131456.278516066@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 29, 2011 at 09:09:03PM +0800, Wu Fengguang wrote:
> Record the readahead pattern in ra->pattern and extend the ra_submit()
> parameters, to be used by the next readahead tracing/stats patches.

I like this, could it be exported it a bit more formally in /proc for 
each file descriptor?

I could imagine a monitoring tool that you run on a process that
tells you what pattern state the various file descriptors are in and how
large the window is. That would be similar to the tools for
monitoring network connections, which are extremly useful 
in practice.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
