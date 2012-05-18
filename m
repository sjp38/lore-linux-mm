Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id AE86B6B0092
	for <linux-mm@kvack.org>; Fri, 18 May 2012 10:25:00 -0400 (EDT)
Date: Fri, 18 May 2012 16:24:43 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] block: Convert BDI proportion calculations to
 flexible proportions
Message-ID: <20120518142443.GA6875@quack.suse.cz>
References: <1337096583-6049-1-git-send-email-jack@suse.cz>
 <1337096583-6049-3-git-send-email-jack@suse.cz>
 <1337292273.4281.101.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337292273.4281.101.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri 18-05-12 00:04:33, Peter Zijlstra wrote:
> On Tue, 2012-05-15 at 17:43 +0200, Jan Kara wrote:
> > +static struct timer_list writeout_period_timer =
> > +               TIMER_DEFERRED_INITIALIZER(writeout_period, 0, 0); 
> 
> So the problem with using a deferred timer is that it 'ignores' idle
> time. So if a very busy period is followed by a real quiet period you'd
> expect all the proportions to have aged to 0, but they won't have.
  Ah, I see. Thanks for warning me.

> One way to solve that is to track a jiffies count of the last time the
> timer triggered and compute the missed periods from that and extend
> fprop_new_period() to deal with period increments of more than 1.
  Yeah, that should be easy enough so I'll try it that way since I presume
it's nicer to power usage to use deferred timers if it's reasonably
possible.

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
