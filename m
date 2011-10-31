Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 94ECC6B002D
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 16:12:27 -0400 (EDT)
Date: Mon, 31 Oct 2011 13:12:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] vmscan: promote shared file mapped pages
Message-Id: <20111031131224.79ca1a2c.akpm@linux-foundation.org>
In-Reply-To: <20110808110658.31053.55013.stgit@localhost6>
References: <20110808110658.31053.55013.stgit@localhost6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 8 Aug 2011 15:06:58 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Commit v2.6.33-5448-g6457474 (vmscan: detect mapped file pages used only once)
> greatly decreases lifetime of single-used mapped file pages.
> Unfortunately it also decreases life time of all shared mapped file pages.
> Because after commit v2.6.28-6130-gbf3f3bc (mm: don't mark_page_accessed in fault path)
> page-fault handler does not mark page active or even referenced.
> 
> Thus page_check_references() activates file page only if it was used twice while
> it stays in inactive list, meanwhile it activates anon pages after first access.
> Inactive list can be small enough, this way reclaimer can accidentally
> throw away any widely used page if it wasn't used twice in short period.
> 
> After this patch page_check_references() also activate file mapped page at first
> inactive list scan if this page is already used multiple times via several ptes.

We have quite a few acks on these two patches, but everyone wants to
see detailed performance testing.  That hasn't happened, and caution
dictates that I hold these patches out of linux-3.2, pending that
testing.

Of course, you're not the only person who can undertake that testing (hint).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
