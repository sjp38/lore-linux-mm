Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 301C36B0023
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:36:49 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Possible sandybridge livelock issue
References: <1305303156.2611.51.camel@mulgrave.site>
Date: Fri, 13 May 2011 09:36:21 -0700
In-Reply-To: <1305303156.2611.51.camel@mulgrave.site> (James Bottomley's
	message of "Fri, 13 May 2011 11:12:36 -0500")
Message-ID: <m262pezhfe.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: x86@kernel.org, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

James Bottomley <James.Bottomley@HansenPartnership.com> writes:
>
> When the hang occurred, kswapd basically pegged one core in 100% system
> time.  This looks like there's something specific to sandybridge that
> causes this type of bad interaction.  I was wondering if it could be
> something to to with a scheduling problem in turbo mode?  Once kswapd
> goes flat out, the core its on will kick into turbo mode, which causes
> it to get preferentially scheduled there, leading to the live lock.

Sounds unlikely to me.

Turbo mode does not affect the scheduler and the cores are (reasonably) 
independent.


> The only evidence I have to support this theory is that when I reproduce
> the problem with PREEMPT, the core pegs at 100% system time and stays
> there even if I turn off the load.  However, if I can execute work that
> causes kswapd to be kicked off the core it's running on, it will calm
> back down and go to sleep.

Turbo mode just makes the CPU faster, but it should not change 
the scheduler decisions.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
