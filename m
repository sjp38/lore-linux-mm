Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EA53F5F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 23:51:03 -0400 (EDT)
Date: Thu, 16 Apr 2009 05:54:43 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] proc: export more page flags in /proc/kpageflags
Message-ID: <20090416035443.GH14687@one.firstfloor.org>
References: <20090414133448.C645.A69D9226@jp.fujitsu.com> <20090414064132.GB5746@localhost> <20090414154606.C665.A69D9226@jp.fujitsu.com> <20090414071159.GV14687@one.firstfloor.org> <20090415131800.GA11191@localhost> <20090415135749.GD14687@one.firstfloor.org> <20090416024133.GA20162@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090416024133.GA20162@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 16, 2009 at 10:41:33AM +0800, Wu Fengguang wrote:
> On Wed, Apr 15, 2009 at 09:57:49PM +0800, Andi Kleen wrote:
> > > That's pretty good separations. I guess it would be convenient to make the
> > > extra kernel flags available under CONFIG_DEBUG_KERNEL?
> > 
> > Yes.
> > 
> > BTW an alternative would be just someone implementing a suitable
> > command/macro in crash(1) and tell the kernel hackers to run that on
> > /proc/kcore. That would have the advantage to not require code.
> 
> Hmm, that would be horrible to code/maintain. i

Actually the bits are enums and crash is able to read C type 
information.

> One major purpose of
> /proc/kpageflags is to export the unstable kernel page flag bits as
> stable ones to user space. 

That's the first case ("administrator"), but not the second one
("kernel hacker")

BTW not saying that crash is the best solution for this, but
it's certainly an serious alternative for the kernel hacker
case. 

> Note that the exact internal flag bits can
> not only change slowly with kernel versions, but more likely with
> different kconfig combinations.

Really? The numbers should be the same, at least for a given
architecture with 32bit/64bit.

> Followed are their detailed locations. Did we found a bug? ;-)

I think all pages > 0 in a larger page are tails.  But I don't
claim to understand all the finer details of compound pages.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
