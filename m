Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 17FAC6B02A4
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 18:45:12 -0400 (EDT)
Subject: Re: [PATCH 4/7] vmscan: convert direct reclaim tracepoint to
 DEFINE_EVENT
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20100716110859.GH13117@csn.ul.ie>
References: <20100716191006.7369.A69D9226@jp.fujitsu.com>
	 <20100716191508.7375.A69D9226@jp.fujitsu.com>
	 <20100716110859.GH13117@csn.ul.ie>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Tue, 20 Jul 2010 18:45:08 -0400
Message-ID: <1279665908.4818.7.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-07-16 at 12:08 +0100, Mel Gorman wrote:
>  
> > +DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_direct_reclaim_end,
> > +
> > +	TP_PROTO(unsigned long nr_reclaimed),
> > +
> > +	TP_ARGS(nr_reclaimed)
> > +);
> > +
> 
> Over 80 columns here too.
> 
> I know I broke it multiple times in my last series because I thought it
> wasn't enforced any more but I got called on it.

Note, The TRACE_EVENT() macros have a bit more leniency to the 80 column
rule.

-- Steve
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
