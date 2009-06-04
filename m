Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E3B3F6B007E
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 08:50:37 -0400 (EDT)
Date: Thu, 4 Jun 2009 20:50:26 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [6/16] HWPOISON: Add various poison checks in
	mm/memory.c
Message-ID: <20090604125026.GA29026@localhost>
References: <20090603846.816684333@firstfloor.org> <20090603184639.1933B1D028F@basil.firstfloor.org> <20090604042603.GA15682@localhost> <20090604051915.GN1065@one.firstfloor.org> <20090604115533.GB22118@localhost> <20090604125228.GZ1065@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090604125228.GZ1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 08:52:28PM +0800, Andi Kleen wrote:
> On Thu, Jun 04, 2009 at 07:55:33PM +0800, Wu Fengguang wrote:
> > On Thu, Jun 04, 2009 at 01:19:15PM +0800, Andi Kleen wrote:
> > > On Thu, Jun 04, 2009 at 12:26:03PM +0800, Wu Fengguang wrote:
> > > > On Thu, Jun 04, 2009 at 02:46:38AM +0800, Andi Kleen wrote:
> > > > >
> > > > > Bail out early when hardware poisoned pages are found in page fault handling.
> > > >
> > > > I suspect this patch is also not absolutely necessary: the poisoned
> > > > page will normally have been isolated already.
> > >
> > > It's needed to prevent new pages comming in when there is a parallel
> > > fault while the memory failure handling is in process.
> > > Otherwise the pages could get remapped in that small window.
> > 
> > This patch makes no difference at least for file pages, including tmpfs.
> 
> I was more thinking of anonymous pages with multiple mappers (e.g.
> COW after fork)

I guess they are handled by do_anonymous_page() or do_wp_page(),
instead of do_linear_fault()/do_nonlinear_fault()?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
