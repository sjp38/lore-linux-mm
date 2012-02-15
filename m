Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 66FFC6B0083
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 18:50:16 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 485DA3EE0B5
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:50:14 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F86845DE52
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:50:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 165CF45DE4F
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:50:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 04B8C1DB803E
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:50:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B3D261DB803B
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 08:50:13 +0900 (JST)
Date: Thu, 16 Feb 2012 08:48:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH v5 0/3] fadvise: support POSIX_FADV_NOREUSE
Message-Id: <20120216084831.0a6ef4f2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120215012957.GA1728@thinkpad>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
	<20120214133337.9de7835b.akpm@linux-foundation.org>
	<20120214225922.GA12394@thinkpad>
	<20120214152220.4f621975.akpm@linux-foundation.org>
	<20120215012957.GA1728@thinkpad>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?UTF-8?B?UMOhZHJhaWc=?= Brady <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, Greg Thelen <gthelen@google.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 15 Feb 2012 02:35:24 +0100
Andrea Righi <andrea@betterlinux.com> wrote:

> On Tue, Feb 14, 2012 at 03:22:20PM -0800, Andrew Morton wrote:
> > On Tue, 14 Feb 2012 23:59:22 +0100
> > Andrea Righi <andrea@betterlinux.com> wrote:
> > 
> > > On Tue, Feb 14, 2012 at 01:33:37PM -0800, Andrew Morton wrote:
> > > > On Sun, 12 Feb 2012 01:21:35 +0100
> > > > Andrea Righi <andrea@betterlinux.com> wrote: 
> > > > And yes, a container-based approach is pretty crude, and one can
> > > > envision applications which only want modified reclaim policy for one
> > > > particualr file.  But I suspect an application-wide reclaim policy
> > > > solves 90% of the problems.
> > > 
> > > I really like the container-based approach. But for this we need a
> > > better file cache control in the memory cgroup; now we have the
> > > accounting of file pages, but there's no way to limit them.
> > 
> > Again, if/whem memcg becomes sufficiently useful for this application
> > we're left maintaining the obsolete POSIX_FADVISE_NOREUSE for ever.
> 
> Yes, totally agree. For the future a memcg-based solution is probably
> the best way to go.
> 
> This reminds me to the old per-memcg dirty memory discussion
> (http://thread.gmane.org/gmane.linux.kernel.mm/67114), cc'ing Greg.
> 
> Maybe the generic feature to provide that could solve both problems is
> a better file cache isolation in memcg.
> 

Can you think of example interface for us ?
I'd like to discuss this in mm-summit if we have a chance.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
