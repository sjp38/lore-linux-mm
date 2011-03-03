Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4438D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 21:02:04 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4F0903EE0C5
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:02:02 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E20F445DE69
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:02:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C842D45DE61
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:02:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B6610E18001
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:02:01 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B39A1DB8038
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:02:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC PATCH 4/5] mm: Add hit/miss accounting for Page Cache
In-Reply-To: <20110302084542.GA20795@elte.hu>
References: <1299055090-23976-4-git-send-email-namei.unix@gmail.com> <20110302084542.GA20795@elte.hu>
Message-Id: <20110303103337.B93C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Mar 2011 11:01:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: kosaki.motohiro@jp.fujitsu.com, Liu Yuan <namei.unix@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, =?ISO-2022-JP?B?RnIbJEJxRXFTGyhCaWM=?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Arnaldo Carvalho de Melo <acme@redhat.com>

> 
> * Liu Yuan <namei.unix@gmail.com> wrote:
> 
> > +		if (likely(!retry_find) && page && PageUptodate(page))
> > +			page_cache_acct_hit(inode->i_sb, READ);
> > +		else
> > +			page_cache_acct_missed(inode->i_sb, READ);
> 
> Sigh.
> 
> This would make such a nice tracepoint or sw perf event. It could be collected in a 
> 'count' form, equivalent to the stats you are aiming for here, or it could even be 
> traced, if someone is interested in such details.
> 
> It could be mixed with other events, enriching multiple apps at once.

Totally agreed.


> But, instead of trying to improve those aspects of our existing instrumentation 
> frameworks, mm/* is gradually growing its own special instrumentation hacks, missing 
> the big picture and fragmenting the instrumentation space some more.
> 
> That trend is somewhat sad.

So, I think thing is, the stat is how much people and how frequently used.
If it is really really really common, /proc/meminfo or similar special place
is good idea. Another example, If the stat can help our MM debugging to
handle LKML bug report, it is worth to have special care. But other almost
else case are better to use generic framework.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
