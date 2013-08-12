Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id DF88A6B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 05:24:00 -0400 (EDT)
Date: Mon, 12 Aug 2013 11:23:53 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: perf, percpu: panic in account_event
Message-ID: <20130812092353.GC27162@twins.programming.kicks-ass.net>
References: <520016D6.8010603@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520016D6.8010603@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: paulus@samba.org, Ingo Molnar <mingo@kernel.org>, acme@ghostprotocols.net, Tejun Heo <tj@kernel.org>, cl@linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, trinity@vger.kernel.org

On Mon, Aug 05, 2013 at 05:19:18PM -0400, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running latest -next kernel,
> I've stumbled on the following spew.
> 
> It seems to happen on the following line in account_event():
> 
> 	if (event->attr.freq)
> 		atomic_inc(&per_cpu(perf_freq_events, cpu));  <--- here
> 

Right, Frederic even send a fix for this already. I suppose holidays got
in the way of getting it merged quickly though, sorry for that.

Merged his fix, will hopefully get it into tip soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
