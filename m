Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0C2746B00C1
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 21:57:48 -0400 (EDT)
Date: Thu, 30 Jul 2009 09:57:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
Message-ID: <20090730015754.GC7326@localhost>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com> <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com> <33307c790907290015m1e6b5666x9c0014cdaf5ed08@mail.gmail.com> <20090729114322.GA9335@localhost> <33307c790907290711s320607b0i79c939104d4c2d61@mail.gmail.com> <20090730010630.GA7326@localhost> <33307c790907291812j40146a96tc2e9c5e097a33615@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <33307c790907291812j40146a96tc2e9c5e097a33615@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Martin Bligh <mbligh@google.com>
Cc: Chad Talbott <ctalbott@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, "sandeen@redhat.com" <sandeen@redhat.com>, Michael Davidson <md@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 30, 2009 at 09:12:26AM +0800, Martin Bligh wrote:
> > I agree on the unification of kupdate and sync paths. In fact I had a
> > patch for doing this. And I'd recommend to do it in two patches:
> > one to fix the congestion case, another to do the code unification.
> >
> > The sync path don't care whether requeue_io() or redirty_tail() is
> > used, because they disregard the time stamps totally - only order of
> > inodes matters (ie. starvation), which is same for requeue_io()/redirty_tail().
> 
> But, as I understand it, both paths share the same lists, so we still have
> to be consistent?

Then let's first unify the code, then fix the congestion case? :)

> Also, you set flags like more_io higher up in sync_sb_inodes() based on
> whether there's anything in s_more_io queue, so it still seems to have
> some effect to me?

Yes, maybe in some rare cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
