Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 600508D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 03:45:53 -0500 (EST)
Date: Wed, 2 Mar 2011 09:45:42 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC PATCH 4/5] mm: Add hit/miss accounting for Page Cache
Message-ID: <20110302084542.GA20795@elte.hu>
References: <no>
 <1299055090-23976-4-git-send-email-namei.unix@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299055090-23976-4-git-send-email-namei.unix@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Yuan <namei.unix@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@redhat.com>


* Liu Yuan <namei.unix@gmail.com> wrote:

> +		if (likely(!retry_find) && page && PageUptodate(page))
> +			page_cache_acct_hit(inode->i_sb, READ);
> +		else
> +			page_cache_acct_missed(inode->i_sb, READ);

Sigh.

This would make such a nice tracepoint or sw perf event. It could be collected in a 
'count' form, equivalent to the stats you are aiming for here, or it could even be 
traced, if someone is interested in such details.

It could be mixed with other events, enriching multiple apps at once.

But, instead of trying to improve those aspects of our existing instrumentation 
frameworks, mm/* is gradually growing its own special instrumentation hacks, missing 
the big picture and fragmenting the instrumentation space some more.

That trend is somewhat sad.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
