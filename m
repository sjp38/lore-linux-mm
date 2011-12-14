Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 6F5046B02D6
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 07:20:46 -0500 (EST)
Date: Wed, 14 Dec 2011 12:20:41 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Fix kswapd livelock on single core, no preempt kernel
Message-ID: <20111214122041.GF3487@suse.de>
References: <1323798271-1452-1-git-send-email-mikew@google.com>
 <1323829490.22361.395.camel@sli10-conroe>
 <CAGTjWtDvmLnNqUoddUCmLVSDN0HcOjtsuFbAs+MFy24JFX-P3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAGTjWtDvmLnNqUoddUCmLVSDN0HcOjtsuFbAs+MFy24JFX-P3g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Waychison <mikew@google.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickens <hughd@google.com>, Greg Thelen <gthelen@google.com>

On Tue, Dec 13, 2011 at 08:36:43PM -0800, Mike Waychison wrote:
> FYI, this was seen with a 2.6.39-based kernel with no-numa, no-memcg
> and swap-enabled.
> 

If this is 2.6.39, can you try applying the commit
[f06590bd: mm: vmscan: correctly check if reclaimer should schedule during shrink_slab]

There have been a few fixes around kswapd hogging the CPU since 2.6.39.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
