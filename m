Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B93CB8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 12:59:32 -0400 (EDT)
Date: Thu, 31 Mar 2011 18:36:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
Message-ID: <20110331163641.GJ12265@random.random>
References: <1301373398.2590.20.camel@mulgrave.site>
 <4D91FC2D.4090602@redhat.com>
 <20110329190520.GJ12265@random.random>
 <BANLkTikDwfQaSGtrKOSvgA9oaRC1Lbx3cw@mail.gmail.com>
 <20110330161716.GA3876@csn.ul.ie>
 <20110330164906.GE12265@random.random>
 <20110331093053.GB3876@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110331093053.GB3876@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Minchan Kim <minchan.kim@gmail.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>

On Thu, Mar 31, 2011 at 10:30:53AM +0100, Mel Gorman wrote:
> Sounds reasonable. I could discuss briefly the scripts I use based on ftrace
> that dump out highorder allocation latencies as it might be useful to others
> if this is the area they are looking at.

I think it's interesting.

> Also sounds good to me.

Ok. BTW, the OOM topic has been removed from schedule for now and it
returned an empty slot, but as Hugh mentioned, it can be brought back
in as needed on the day.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
