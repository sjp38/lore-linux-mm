Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 1CEE26B004F
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 17:56:02 -0500 (EST)
Date: Fri, 16 Dec 2011 14:56:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/11] Reduce compaction-related stalls and improve
 asynchronous migration of dirty pages v6
Message-Id: <20111216145600.908fc77e.akpm@linux-foundation.org>
In-Reply-To: <1323877293-15401-1-git-send-email-mgorman@suse.de>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 14 Dec 2011 15:41:22 +0000
Mel Gorman <mgorman@suse.de> wrote:

> Short summary: There are severe stalls when a USB stick using VFAT
> is used with THP enabled that are reduced by this series. If you are
> experiencing this problem, please test and report back and considering
> I have seen complaints from openSUSE and Fedora users on this as well
> as a few private mails, I'm guessing it's a widespread issue. This
> is a new type of USB-related stall because it is due to synchronous
> compaction writing where as in the past the big problem was dirty
> pages reaching the end of the LRU and being written by reclaim.
> 
> Am cc'ing Andrew this time and this series would replace
> mm-do-not-stall-in-synchronous-compaction-for-thp-allocations.patch.
> I'm also cc'ing Dave Jones as he might have merged that patch to Fedora
> for wider testing and ideally it would be reverted and replaced by
> this series.

So it appears that the problem is painful for distros and users and
that we won't have this fixed until 3.2 at best, and that fix will be a
difficult backport for distributors of earlier kernels.

To serve those people better, I'm wondering if we should merge
mm-do-not-stall-in-synchronous-compaction-for-thp-allocations now, make
it available for -stable backport and then revert it as part of this
series?   ie: give people a stopgap while we fix it properly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
