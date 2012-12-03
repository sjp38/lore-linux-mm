Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 9DA186B0044
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 13:28:50 -0500 (EST)
Date: 3 Dec 2012 13:28:48 -0500
Message-ID: <20121203182848.5536.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: 3.7-rc6 soft lockup in kswapd0
In-Reply-To: <20121129145414.9415.qmail@science.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, mgorman@suse.de
Cc: dave@linux.vnet.ibm.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com

> Almost three days, when it wouldn't live overnight before.
> As promised, I'm declaring victory.
> 
> The patch that worked (on top of -rc7) was Johannes Weiner's
> "mm: vmscan: fix endless loop in kswapd balancing"
> that added the zone_balanced() function to mm/vmscan.c:2400.
> 
> Thank you all very much!

Further update, uptime is now 1 week with no more problems.

Just checked dmesg; no complaints.  And kswapd0 is showing 0:09.08 of
CPU time for the week, more than cron but less than init.

Tested-by: George Spelvin <linux@horizon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
