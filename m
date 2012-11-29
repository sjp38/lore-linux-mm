Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id B0CC66B0081
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 12:09:30 -0500 (EST)
Date: Thu, 29 Nov 2012 12:08:43 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: 3.7-rc6 soft lockup in kswapd0
Message-ID: <20121129170843.GJ2301@cmpxchg.org>
References: <20121128113920.GU8218@suse.de>
 <20121129145414.9415.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121129145414.9415.qmail@science.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: mgorman@suse.de, dave@linux.vnet.ibm.com, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com

On Thu, Nov 29, 2012 at 09:54:14AM -0500, George Spelvin wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> > On Tue, Nov 27, 2012 at 04:25:14PM -0500, George Spelvin wrote:
> >> Well, it just made it to 24 hours, 
> >> it did before.  I'm going to wait a couple more days before declaring
> >> victory, but it looks good so far.
> >> 
> >>  19:19:10 up 1 day, 0 min,  2 users,  load average: 0.15, 0.20, 0.22
> >>  21:24:05 up 1 day,  2:05,  2 users,  load average: 0.25, 0.19, 0.18
> >
> > Superb. The relevant patches *should* be in flight for 3.7 assuming they
> > make it through the confusion of last-minute fixes.
> 
>  14:53:54 up 2 days, 19:35,  2 users,  load average: 0.20, 0.24, 0.23
> 
> Almost three days, when it wouldn't live overnight before.
> As promised, I'm declaring victory.
> 
> The patch that worked (on top of -rc7) was Johannes Weiner's
> "mm: vmscan: fix endless loop in kswapd balancing"
> that added the zone_balanced() function to mm/vmscan.c:2400.

Thanks for testing!

Love,
Georgina

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
