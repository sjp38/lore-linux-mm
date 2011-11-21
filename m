Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 63F266B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 09:01:19 -0500 (EST)
Subject: Re: [PATCH 6/8] readahead: add debug tracing event
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20111121093846.764030336@intel.com>
References: <20111121091819.394895091@intel.com>
	 <20111121093846.764030336@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 21 Nov 2011 09:01:15 -0500
Message-ID: <1321884075.20742.5.camel@frodo>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

On Mon, 2011-11-21 at 17:18 +0800, Wu Fengguang wrote:
> plain text document attachment (readahead-tracer.patch)
> This is very useful for verifying whether the algorithms are working
> to our expectaions.
> 
> Example output:
> 
> # echo 1 > /debug/tracing/events/vfs/readahead/enable
> # cp test-file /dev/null
> # cat /debug/tracing/trace  # trimmed output
> readahead-initial(dev=0:15, ino=100177, req=0+2, ra=0+4-2, async=0) = 4
> readahead-subsequent(dev=0:15, ino=100177, req=2+2, ra=4+8-8, async=1) = 8
> readahead-subsequent(dev=0:15, ino=100177, req=4+2, ra=12+16-16, async=1) = 16
> readahead-subsequent(dev=0:15, ino=100177, req=12+2, ra=28+32-32, async=1) = 32
> readahead-subsequent(dev=0:15, ino=100177, req=28+2, ra=60+60-60, async=1) = 24
> readahead-subsequent(dev=0:15, ino=100177, req=60+2, ra=120+60-60, async=1) = 0
> 
> CC: Ingo Molnar <mingo@elte.hu>
> CC: Jens Axboe <jens.axboe@oracle.com>
> CC: Steven Rostedt <rostedt@goodmis.org>

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
