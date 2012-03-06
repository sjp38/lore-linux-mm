Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 3F71C6B0092
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 13:17:21 -0500 (EST)
Message-ID: <1331057839.2140.12.camel@joe2Laptop>
Subject: Re: [RFC PATCH] checkpatch: Warn on use of yield()
From: Joe Perches <joe@perches.com>
Date: Tue, 06 Mar 2012 10:17:19 -0800
In-Reply-To: <1331056859.2140.7.camel@joe2Laptop>
References: <20120302112358.GA3481@suse.de>
	 <1330723262.11248.233.camel@twins>
	 <20120305121804.3b4daed4.akpm@linux-foundation.org>
	 <1330999280.10358.3.camel@joe2Laptop> <1331037942.11248.307.camel@twins>
	 <1331055666.2140.3.camel@joe2Laptop> <1331056466.11248.327.camel@twins>
	 <1331056859.2140.7.camel@joe2Laptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Miao Xie <miaox@cn.fujitsu.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>

On Tue, 2012-03-06 at 10:00 -0800, Joe Perches wrote:
> On Tue, 2012-03-06 at 18:54 +0100, Peter Zijlstra wrote:
> > On Tue, 2012-03-06 at 09:41 -0800, Joe Perches wrote:
> > > Perhaps the kernel-doc comments in sched/core.c
> > > should/could be expanded/updated. 
> > Something like this?
[]
> > diff --git a/kernel/sched/core.c b/kernel/sched/core.c
[]
> > @@ -4577,8 +4577,24 @@ EXPORT_SYMBOL(__cond_resched_softirq);
> >  /**
> >   * yield - yield the current processor to other threads.

Perhaps the phrase "other threads" is poor word choice.  Maybe:

yield - yield the current processor to a runnable thread
        (might be the current thread)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
