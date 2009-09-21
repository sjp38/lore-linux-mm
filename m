Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2E4026B0143
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 07:17:48 -0400 (EDT)
Date: Mon, 21 Sep 2009 12:17:48 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 2/4] send callback when swap slot is freed
In-Reply-To: <4AB6441D.5070805@vflare.org>
Message-ID: <Pine.LNX.4.64.0909211207520.32504@sister.anvils>
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>
 <1253227412-24342-3-git-send-email-ngupta@vflare.org>
 <1253256805.4959.8.camel@penberg-laptop>  <Pine.LNX.4.64.0909180809290.2882@sister.anvils>
  <1253260528.4959.13.camel@penberg-laptop>  <Pine.LNX.4.64.0909180857170.5404@sister.anvils>
 <1253266391.4959.15.camel@penberg-laptop> <4AB3A16B.90009@vflare.org>
 <4AB487FD.5060207@cs.helsinki.fi> <4AB6441D.5070805@vflare.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Sun, 20 Sep 2009, Nitin Gupta wrote:
> 
> Ok, lets discard all this.

I think we don't have the right infrastructure even for discard yet ;)

> I will soon start working on a generic notifier based
> interface for various swap events: swapon, swapoff, swap slot free that I hope would
> be more acceptable. I will now surely miss this merge window but I hope the end result
> would be better.

Don't worry about missing the merge window, I think it was already missed.
But beware of overdesign: who will be using these notifiers than you?

That's a rhetorical question: I just don't want you expending your time
on something fancy, then see it rejected next time around.  If you can
convince that what you come up with will be generally useful, great,
it'll go in; but I'm not interested in window dressing.

> 
> The issue of swap_lock is still bugging me but I think atomic notifier list should
> be acceptable for swap slot free event, at least for the initial revision. If this
> particular event finds more users then we will have to work on reducing contention
> on swap_lock (per-swap file lock?).

The swap_lock in swap_free is troubling, and argues strongly against
pretending a general interface; but I quite understand your difficulty
in doing without it, it was awkward when I tried to discard near there.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
