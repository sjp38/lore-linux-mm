Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A064E6B0044
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 18:19:18 -0400 (EDT)
Message-ID: <4F69022D.3080300@redhat.com>
Date: Tue, 20 Mar 2012 18:18:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 00/26] sched/numa
References: <20120316144028.036474157@chello.nl>  <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins>  <20120319130401.GI24602@redhat.com> <1332163591.18960.334.camel@twins>  <20120319135745.GL24602@redhat.com> <4F673D73.90106@redhat.com>  <20120319143002.GQ24602@redhat.com> <1332182523.18960.372.camel@twins>
In-Reply-To: <1332182523.18960.372.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/19/2012 02:42 PM, Peter Zijlstra wrote:
> On Mon, 2012-03-19 at 15:30 +0100, Andrea Arcangeli wrote:
>
>> I agree for qemu those soft bindings are fine.
>
> So for what exact program(s) are you working? Your solution seems purely
> focused on the hard case of a multi-threaded application that's larger
> than a single node.
>
> While I'm sure such applications exist, how realistic is it that they're
> the majority?

I suspect Java and other runtimes may have issues where
they simply do not know which thread will end up using
which objects from the heap heavily.

However, even for those migrate-on-fault could be a
reasonable alternative to scanning + proactive migration.

It is really too early to tell which of the approaches is
going to work best.

>> When you focus only on the cost of collecting the information and no
>> actual discussion was spent yet on how to compute or react to it,
>> something's wrong... as that's the really interesting part of the code.
>
> Yeah, the thing that's wrong is you dumping a ~2300 line patch of dense
> code over the wall without any high-level explanation.
>
> I just about got to the policy parts but its not like its easy reading.
>
> Also, you giving clues but not really saying what you mean attitude
> combined with your tendency to write books instead of emails isn't
> really conductive to me wanting to ask for any explanation either.

Getting high level documentation of the ideas behind both
of the NUMA implementations could really help smooth out
the debate.

The more specifics on the ideas and designs we have, the
easier it will be to look past small details in the code
and debate the merits of the design (before we get to
cleaning up whichever bits of code we end up choosing).

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
