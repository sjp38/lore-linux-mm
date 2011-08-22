Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AC3B16B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 19:23:02 -0400 (EDT)
Date: Tue, 23 Aug 2011 09:22:57 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] vmscan: fix initial shrinker size handling
Message-ID: <20110822232257.GT3162@dastard>
References: <20110822101721.19462.63082.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110822101721.19462.63082.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon, Aug 22, 2011 at 02:17:21PM +0300, Konstantin Khlebnikov wrote:
> Shrinker function can returns -1, it means it cannot do anything without a risk of deadlock.
> For example prune_super() do this if it cannot grab superblock refrence, even if nr_to_scan=0.
> Currenly we interpret this like ULONG_MAX size shrinker, evaluate total_scan according this,
> and next time this shrinker can get really big pressure. Let's skip such shrinkers instead.
> 
> Also make total_scan signed, otherwise check (total_scan < 0) below never works.

I've got a patch set I am going to post out today that makes this
irrelevant.

The patch set splits the shrinker api into 2 callbacks - a "count
objects" callback and an "scan objects" callback, getting rid of
this messy "pass nr-to_scan == 0 to count objects" wart altogether.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
