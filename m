Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B998C8D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 07:54:10 -0500 (EST)
Date: Thu, 3 Feb 2011 13:53:57 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/2] memcg: clean up limit checking
Message-ID: <20110203125357.GA2286@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
 <1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
 <20110131144131.6733aa3a.akpm@linux-foundation.org>
 <20110201000455.GB19534@cmpxchg.org>
 <20110131162448.e791f0ae.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110131162448.e791f0ae.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 31, 2011 at 04:24:48PM -0800, Andrew Morton wrote:
> On Tue, 1 Feb 2011 01:04:55 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Maybe it would be better to use res_counter_margin(cnt) >= wanted
> > throughout the code.
> 
> yup.

Okay, I cleaned it all up a bit for .39.  While doing so, I also found
that we are reclaiming one page too much when pushing back on behalf
of soft limits.

So 1/2 fixes the soft limit reclaim off-by-one-page, and 2/2 reduces
all the limit checks to two functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
