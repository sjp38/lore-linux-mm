Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5C5A16B005A
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 14:26:28 -0400 (EDT)
Message-ID: <4A36925D.4090000@redhat.com>
Date: Mon, 15 Jun 2009 14:26:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] mm tracepoints update - use case.
References: <1240402037.4682.3.camel@dhcp47-138.lab.bos.redhat.com> <1240428151.11613.46.camel@dhcp-100-19-198.bos.redhat.com> <20090423092933.F6E9.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090423092933.F6E9.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, =?UTF-8?B?RnLpppjpp7tpYyBXZWlzYmVja2Vy?= <fweisbec@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>> On Wed, 2009-04-22 at 08:07 -0400, Larry Woodman wrote:

>> Attached is an example of what the mm tracepoints can be used for:
> 
> I have some comment.
> 
> 1. Yes, current zone_reclaim have strange behavior. I plan to fix
>    some bug-like bahavior.
> 2. your scenario only use the information of "zone_reclaim called".
>    function tracer already provide it.
> 3. but yes, you are going to proper direction. we definitely need
>    some fine grained tracepoint in this area. we are welcome to you.
>    but in my personal feeling, your tracepoint have worthless argument
>    a lot. we need more good information.
>    I think I can help you in this area. I hope to work together.

Sorry I am replying to a really old email, but exactly
what information do you believe would be more useful to
extract from vmscan.c with tracepoints?

What are the kinds of problems that customer systems
(which cannot be rebooted into experimental kernels)
run into, that can be tracked down with tracepoints?

I can think of a few:
- excessive CPU use in page reclaim code
- excessive reclaim latency in page reclaim code
- unbalanced memory allocation between zones/nodes
- strange balance problems between reclaiming of page
   cache and swapping out process pages

I suspect we would need fairly fine grained tracepoints
to track down these kinds of problems, with filtering
and/or interpretation in userspace, but I am always
interested in easier ways of tracking down these kinds
of problems :)

What kinds of tracepoints do you believe we would need?

Or, using Larry's patch as a starting point, what do you
believe should be changed?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
