Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAF76B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 19:38:26 -0400 (EDT)
Date: Mon, 22 Aug 2011 16:38:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] vmscan: fix initial shrinker size handling
Message-Id: <20110822163821.e746ab25.akpm@linux-foundation.org>
In-Reply-To: <20110822232257.GT3162@dastard>
References: <20110822101721.19462.63082.stgit@zurg>
	<20110822232257.GT3162@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 23 Aug 2011 09:22:57 +1000
Dave Chinner <david@fromorbit.com> wrote:

> On Mon, Aug 22, 2011 at 02:17:21PM +0300, Konstantin Khlebnikov wrote:
> > Shrinker function can returns -1, it means it cannot do anything without a risk of deadlock.
> > For example prune_super() do this if it cannot grab superblock refrence, even if nr_to_scan=0.
> > Currenly we interpret this like ULONG_MAX size shrinker, evaluate total_scan according this,
> > and next time this shrinker can get really big pressure. Let's skip such shrinkers instead.
> > 
> > Also make total_scan signed, otherwise check (total_scan < 0) below never works.
> 
> I've got a patch set I am going to post out today that makes this
> irrelevant.

Well, how serious is the bug?  If it's a non-issue then we can leave
the fix until 3.1.  If it's a non-non-issue then we'd need a minimal
patch to fix up 3.1 and 3.0.x.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
