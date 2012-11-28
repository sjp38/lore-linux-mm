Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 797EE6B0072
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 06:39:26 -0500 (EST)
Date: Wed, 28 Nov 2012 11:39:20 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: 3.7-rc6 soft lockup in kswapd0
Message-ID: <20121128113920.GU8218@suse.de>
References: <20121126190926.GM8218@suse.de>
 <20121127212514.1173.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121127212514.1173.qmail@science.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: dave@linux.vnet.ibm.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com

On Tue, Nov 27, 2012 at 04:25:14PM -0500, George Spelvin wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> > On Mon, Nov 26, 2012 at 01:53:17PM -0500, George Spelvin wrote:
> >> Johannes Weiner <hannes@cmpxchg.org> wrote:
> >>> Any chance you could test with this fix instead, in addition to Dave's
> >>> accounting fix?  It's got bool and everything!
> > 
> >> Okay.  Mel, speak up if you object.  I also rebased on top of 3.7-rc7,
> >> which already includes Dave's fix.  Again, speak up if that's a bad idea.
> > 
> > No objections all round.
> 
> Well, it just made it to 24 hours, 
> it did before.  I'm going to wait a couple more days before declaring
> victory, but it looks good so far.
> 
>  19:19:10 up 1 day, 0 min,  2 users,  load average: 0.15, 0.20, 0.22
>  21:24:05 up 1 day,  2:05,  2 users,  load average: 0.25, 0.19, 0.18

Superb. The relevant patches *should* be in flight for 3.7 assuming they
make it through the confusion of last-minute fixes.

Thanks

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
