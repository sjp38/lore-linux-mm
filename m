Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8EB526B0047
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 03:33:27 -0500 (EST)
Date: Thu, 10 Dec 2009 09:33:10 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC mm][PATCH 2/5] percpu cached mm counter
Message-ID: <20091210083310.GB6834@elte.hu>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
 <20091210163448.338a0bd2.kamezawa.hiroyu@jp.fujitsu.com>
 <20091210075454.GB25549@elte.hu>
 <20091210172040.37d259d3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091210172040.37d259d3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>


* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> I'm sorry If I miss your point...are you saying remove all mm_counter 
> completely and remake them under perf ? If so, some proc file 
> (/proc/<pid>/statm etc) will be corrupted ?

No, i'm not suggesting that - i'm just suggesting that right now MM 
stats are not very well suited to be exposed via perf. If we wanted to 
measure/sample the information in /proc/<pid>/statm it just wouldnt be 
possible. We have a few events like pagefaults and a few tracepoints as 
well - but more would be possible IMO.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
