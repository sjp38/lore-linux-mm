Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7C5436B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 19:28:56 -0400 (EDT)
Date: Tue, 23 Aug 2011 09:28:34 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] vmscan: fix initial shrinker size handling
Message-ID: <20110822232834.GV3162@dastard>
References: <20110822101721.19462.63082.stgit@zurg>
 <20110822143006.60f4b560.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110822143006.60f4b560.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 22, 2011 at 02:30:06PM -0700, Andrew Morton wrote:
> On Mon, 22 Aug 2011 14:17:21 +0300
> Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:
> 
> > Shrinker function can returns -1, it means it cannot do anything without a risk of deadlock.
> > For example prune_super() do this if it cannot grab superblock refrence, even if nr_to_scan=0.
> > Currenly we interpret this like ULONG_MAX size shrinker, evaluate total_scan according this,
> > and next time this shrinker can get really big pressure. Let's skip such shrinkers instead.
> 
> Yes, that looks like a significant oversight.
> 
> > Also make total_scan signed, otherwise check (total_scan < 0) below never works.
> 
> Hopefully a smaller oversight.

Yeah, it was, but is harmless because it is caught by the next check
of total_scanned. I've made similar "make everything signed" changes
as well.

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
