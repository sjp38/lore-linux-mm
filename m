Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 093966B0092
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 15:18:06 -0500 (EST)
Date: Mon, 5 Mar 2012 12:18:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] cpuset: mm: Remove memory barrier damage from the page
 allocator
Message-Id: <20120305121804.3b4daed4.akpm@linux-foundation.org>
In-Reply-To: <1330723262.11248.233.camel@twins>
References: <20120302112358.GA3481@suse.de>
	<1330723262.11248.233.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Mel Gorman <mgorman@suse.de>, Miao Xie <miaox@cn.fujitsu.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joe Perches <joe@perches.com>

On Fri, 02 Mar 2012 22:21:02 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Fri, 2012-03-02 at 11:23 +0000, Mel Gorman wrote:
> > For extra style points, the commit introduced the use of yield() in an
> > implementation of what looks like a spinning mutex.
> 
> Andrew, could you simply say no to any patch adding a yield()? There's a
> 99% chance its a bug, as was this. 

I'd normally at least poke my tongue out at it - I must have missed
this one.

> This code would life-lock when cpuset_change_task_nodemask() would be
> called by the highest priority FIFO task on UP or when pinned to the
> same cpu the task doing get_mems_allowed().

Joe, can we please have a checkpatch rule?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
