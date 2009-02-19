Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0D9A16B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 08:12:20 -0500 (EST)
Received: by wa-out-1112.google.com with SMTP id k22so217419waf.22
        for <linux-mm@kvack.org>; Thu, 19 Feb 2009 05:12:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <499CE2FE.90503@bk.jp.nec.com>
References: <1234863220.4744.34.camel@laptop> <499A99BC.2080700@bk.jp.nec.com>
	 <20090217201651.576E.A69D9226@jp.fujitsu.com>
	 <499CE2FE.90503@bk.jp.nec.com>
Date: Thu, 19 Feb 2009 22:12:17 +0900
Message-ID: <2f11576a0902190512y1ac60b11s4927533977dc01e7@mail.gmail.com>
Subject: Re: [PATCH] Add tracepoints to track pagecache transition
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, Jason Baron <jbaron@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mathieu Desnoyers <compudj@krystal.dyndns.org>, "Frank Ch. Eigler" <fche@redhat.com>, Kazuto Miyoshi <miyoshi@linux.bs1.fc.nec.co.jp>, rostedt@goodmis.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

> Hi Kosaki-san,
>
> Thank you for your comment.
>
> KOSAKI Motohiro wrote:
>> Hi
>>
>>
>> In my 1st impression, this patch description is a bit strange.
>>
>>> The below patch adds instrumentation for pagecache.
>>>
>>> I thought it would be useful to trace pagecache behavior for problem
>>> analysis (performance bottlenecks, behavior differences between stable
>>> time and trouble time).
>>>
>>> By using those tracepoints, we can describe and visualize pagecache
>>> transition (file-by-file basis) in kernel and  pagecache
>>> consumes most of the memory in running system and pagecache hit rate
>>> and writeback behavior will influence system load and performance.
>>
>> Why do you think this tracepoint describe pagecache hit rate?
>> and, why describe writeback behavior?
>
> I mean, we can describe file-by-file basis pagecache usage by using
> these tracepoints and it is important for analyzing process I/O behavior.

More confusing.
Your page cache tracepoint don't have any per-process information.


> Currently, we can understand the amount of pagecache from "Cached"
> in /proc/meminfo. So I'd like to understand which files are using pagecache.

There is one meta question, Why do you think file-by-file pagecache
infomartion is valueable?


>>> I attached an example which is visualization of pagecache status using
>>> SystemTap.
>>
>> it seems no attached. and SystemTap isn't used kernel developer at all.
>> I don't think it's enough explanation.
>> Can you make seekwatcher liked completed comsumer program?
>> (if you don't know seekwatcher, see http://oss.oracle.com/~mason/seekwatcher/)
>
> I understand a tracer using these tracepoints need to be implemented.
> What I want to do is counting pagecache per file. We can retrieve inode
> from mapping and count pagecache per inode in these tracepoints.
>
>
>>> That graph describes pagecache transition of File A and File B
>>> on a file-by-file basis with the situation where regular I/O to File A
>>> is delayed because of other I/O to File B.
>>
>> If you want to see I/O activity, you need to add tracepoint into block layer.
>
> I think tracking pagecache is useful for understanding process I/O activity,
> because whether process I/O completes by accessing memory or HDD is determined by
> accessed files on pagecache or not.

I don't know your opinion is right or not.
However, your opinion don't get consensus yet.

Perhaps, you need to make demonstrate programs, I think.


>> And, both function is freqentlly called one.
>> I worry about performance issue. can you prove no degression?
>
> I will try to probe that.

Perhaps, this is not needed yet.
Generally, worthless patch is never merged although it's no performance penalty.
So, I think you should explain the patch worth at first :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
