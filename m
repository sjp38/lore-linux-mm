Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 33F536B00D4
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 04:51:24 -0500 (EST)
Date: Thu, 15 Dec 2011 10:49:22 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] proc: show readahead state in fdinfo
Message-ID: <20111215094922.GA29981@elte.hu>
References: <20111129130900.628549879@intel.com>
 <20111129131456.278516066@intel.com>
 <20111129175743.GP24062@one.firstfloor.org>
 <20111215085540.GA23966@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111215085540.GA23966@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Arnaldo Carvalho de Melo <acme@redhat.com>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Wed, Nov 30, 2011 at 01:57:43AM +0800, Andi Kleen wrote:
> > On Tue, Nov 29, 2011 at 09:09:03PM +0800, Wu Fengguang wrote:
> > > Record the readahead pattern in ra->pattern and extend the ra_submit()
> > > parameters, to be used by the next readahead tracing/stats patches.
> > 
> > I like this, could it be exported it a bit more formally in /proc for 
> > each file descriptor?
> 
> How about this?
> ---
> Subject: proc: show readahead state in fdinfo
> Date: Thu Dec 15 14:35:56 CST 2011
> 
> Append three readahead states to /proc/<PID>/fdinfo/<FD>:

Not a very good idea - please keep debug info under /debug as 
much as possible (as your original series did), instead of 
creating an ad-hoc insta-ABI in /proc.

In the long run we'd really like to retrieve such kind of 
information not even via ad-hoc exported info in /debug but via 
the standard event facilities: the tracepoints, if they are 
versatile enough, could be used to collect these stats and more.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
