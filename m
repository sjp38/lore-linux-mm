Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2AA836B01FD
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 23:57:30 -0400 (EDT)
Date: Wed, 28 Apr 2010 22:57:18 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH v2] - Randomize node rotor used in
 cpuset_mem_spread_node()
Message-ID: <20100429035718.GT4920@sgi.com>
References: <20100428131158.GA2648@sgi.com>
 <20100428150432.GA3137@sgi.com>
 <20100428154034.fb823484.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100428154034.fb823484.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 28, 2010 at 03:40:34PM -0700, Andrew Morton wrote:
> On Wed, 28 Apr 2010 10:04:32 -0500
> Jack Steiner <steiner@sgi.com> wrote:
> 
> > Some workloads that create a large number of small files tend to assign
> > too many pages to node 0 (multi-node systems). Part of the reason is that
> > the rotor (in cpuset_mem_spread_node()) used to assign nodes starts
> > at node 0 for newly created tasks.
> 
> And, presumably, your secret testcase forks lots of subprocesses which
> do the file creation?

I think the test case he was using was aim7 or a kernel compile.
Anything that opens a lot of small files will quickly deplete node 0.

> > This patch changes the rotor to be initialized to a random node number
> > of the cpuset.
> 
> Why random as opposed to, say, inherit-rotor-from-parent?

If I have something like a find ... -exec grep ..., won't the pages
be biased towards the nodes adjacent to the parent's rotor values.
Maybe I misunderstood Jack's problem, but I believe that was what he
was seeing and why he chose random.

I hope I did not misunderstand Jack's problem and mislead this discussion.

Thanks,
Robin Holt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
