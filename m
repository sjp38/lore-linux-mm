Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E9CF86B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 20:30:13 -0400 (EDT)
Message-ID: <4E31FEB3.4060708@bx.jp.nec.com>
Date: Thu, 28 Jul 2011 20:28:35 -0400
From: Keiichi KII <k-keiichi@bx.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH -tip 0/5] perf tools: pagecache monitoring
References: <4E24A61D.4060702@bx.jp.nec.com> <20110721070129.GA9216@elte.hu>
In-Reply-To: <20110721070129.GA9216@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tom Zanussi <tzanussi@gmail.com>, "riel@redhat.com" <riel@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Fr??d??ric Weisbecker <fweisbec@gmail.com>, "BA, Moussa" <Moussa.BA@numonyx.com>

>> My patches are based on the latest "linux-tip.git" tree and
>> also the following 3 commits in "tip:tracing/mm" and a "pagecache
>> object collections" patch. 
>>
>>   - dcac8cd: tracing/mm: add page frame snapshot trace
>>   - 1487a7a: tracing/mm: fix mapcount trace record field
>>   - eb46710: tracing/mm: rename 'trigger' file to 'dump_range'
>>   - http://lkml.org/lkml/2010/2/9/156
>>
>> Any comments are welcome.
> 
> I totally like the approach you have taken here.
> 
> Note that tracepoints need a detailed, careful review from interested 
> mm folks.
> 
> The set of tracepoints does not have to be complete but the 
> tracepoints have to be well thought out and near-perfect in this 
> context they are instrumenting, with an eye on future extensions with 
> the goal of making them painless.
> 
> the pagecache tracepoints you have added are:
> 
>  include/trace/events/filemap.h |   75 ++++++++++++++++++++++++++++++++++++++++
>  mm/filemap.c                   |    4 ++
>  mm/truncate.c                  |    2 +
>  mm/vmscan.c                    |    2 +
>  4 files changed, 83 insertions(+), 0 deletions(-)
> 
> So once such kind of review has been iterated through and Andrew et 
> al is happy with it i'd be more than happy to dust off the tracing/mm 
> bits (which have been done two years ago) and get it all to Linus.
> 
> Andrew, Mel, Fengguang?

Thank you for your comments. 
And I agree the tracepoints need reviews from mm folks.
I think the patches in tracing/mm are useful for monitoring mm behavior.
Is there any comments for these patches(especially the tracepoints)?
Any comments are welcome.

Thanks,
Keiichi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
