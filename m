Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9044D6B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 04:34:09 -0400 (EDT)
Date: Tue, 21 Apr 2009 17:29:33 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: mmotm 2009-04-17-15-19 uploaded
Message-ID: <20090421082933.GA16026@linux-sh.org>
References: <200904172238.n3HMc2RA018806@imap1.linux-foundation.org> <20090421172939.803fcd1e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090421172939.803fcd1e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 05:29:39PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 17 Apr 2009 15:19:22 -0700
> akpm@linux-foundation.org wrote:
> 
> > The mm-of-the-moment snapshot 2009-04-17-15-19 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > and will soon be available at
> > 
> >    git://git.zen-sources.org/zen/mmotm.git
> > 
> > It contains the following patches against 2.6.30-rc2:
> > 
> Can I make a question ?
> 
> It seems SLQB is a default slab allocator in this mmotm.
> Which is the reason ? "do more test!" or "it's better in general!!!"
> 
Given that it doesn't even compile on several platforms, I vote for the
former ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
