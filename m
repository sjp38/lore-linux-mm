Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 0AA308D0002
	for <linux-mm@kvack.org>; Fri, 11 May 2012 19:24:34 -0400 (EDT)
Received: by qabg27 with SMTP id g27so2119031qab.14
        for <linux-mm@kvack.org>; Fri, 11 May 2012 16:24:34 -0700 (PDT)
Message-ID: <4FAD9FAF.4050905@gmail.com>
Date: Fri, 11 May 2012 19:24:31 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: Allow migration of mlocked page?
References: <4FAC9786.9060200@kernel.org> <1336728026.1017.7.camel@twins> <alpine.DEB.2.00.1205111117380.31049@router.home>
In-Reply-To: <alpine.DEB.2.00.1205111117380.31049@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>, kosaki.motohiro@gmail.com

(5/11/12 12:20 PM), Christoph Lameter wrote:
> On Fri, 11 May 2012, Peter Zijlstra wrote:
>
>> On Fri, 2012-05-11 at 13:37 +0900, Minchan Kim wrote:
>>> I hope hear opinion from rt guys, too.
>>
>> Its a problem yes, not sure your solution is any good though. As it
>> stands mlock() simply doesn't guarantee no faults, all it does is
>> guarantee no major faults.
>
> There are two different way to lock pages down in memory that have
> different counters in /proc/<pid>/status and also different semantics.
>
> VmLck: Mlocked pages. This means there is a prohibition against evicting
> pages. These pages can undergo page migration and therefore also be
> handled by compation. These pages have PG_mlock set.
>
> VmPin: Pinned pages. Page cannot be moved. These pages have an elevated
> refcount that makes page migration fail.

I don't see VmPin counter in my box. Did you introduce this one recently?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
