Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 8EC296B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 14:02:54 -0500 (EST)
Received: by vbnl22 with SMTP id l22so769228vbn.14
        for <linux-mm@kvack.org>; Thu, 12 Jan 2012 11:02:53 -0800 (PST)
Message-ID: <4F0F2E5A.3070602@gmail.com>
Date: Thu, 12 Jan 2012 14:02:50 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] mm: Remove NUMA_INTERLEAVE_HIT
References: <1326380820.2442.186.camel@twins> <20120112182644.GE11715@one.firstfloor.org>
In-Reply-To: <20120112182644.GE11715@one.firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

(1/12/12 1:26 PM), Andi Kleen wrote:
> On Thu, Jan 12, 2012 at 04:07:00PM +0100, Peter Zijlstra wrote:
>> Since the NUMA_INTERLEAVE_HIT statistic is useless on its own; it wants
>> to be compared to either a total of interleave allocations or to a miss
>> count, remove it.
>
> Nack!
>
> This would break the numactl testsuite.

This seems slightly strange reason to me. Almost useless/deprecated feature removement broke ltp testsuite. But endusers never complained. Because they never use testcases for development. So, May I clarify your intention? To use Documention/feature-removal-schedule.txt solve your worry?

Personally, I haven't observed NUMA_INTERLEAVE_HIT is used on production environment. But, I also haven't
felt this feature is a code maintenance bottleneck. So, I'd like to just ask.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
