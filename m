Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 6C4F06B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 12:52:52 -0400 (EDT)
Date: Tue, 12 Mar 2013 12:52:47 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Swap defragging
Message-ID: <20130312165247.GB1953@cmpxchg.org>
References: <CAGDaZ_rvfrBVCKMuEdPcSod684xwbUf9Aj4nbas4_vcG3V9yfg@mail.gmail.com>
 <20130308023511.GD23767@cmpxchg.org>
 <513A97C5.7020008@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <513A97C5.7020008@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: Raymond Jennings <shentino@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, Mar 09, 2013 at 10:00:37AM +0800, Will Huck wrote:
> Hi Johannes,
> On 03/08/2013 10:35 AM, Johannes Weiner wrote:
> >On Thu, Mar 07, 2013 at 06:07:23PM -0800, Raymond Jennings wrote:
> >>Just a two cent question, but is there any merit to having the kernel
> >>defragment swap space?
> >That is a good question.
> >
> >Swap does fragment quite a bit, and there are several reasons for
> >that.
> 
> Are there any tools to test and monitor swap subsystem and page
> reclaim subsystem?

seekwatcher is great to see the IO patterns.  Anything that uses
anonymous memory can test swap: a java job, multiplying matrixes,
kernel builds etc.  I mostly log /proc/vmstat by taking snapshots at a
regular interval during the workload, then plot and visually correlate
the swapin/swapout counters with the individual LRU sizes, page fault
rate, what have you, to get a feeling for what it's doing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
