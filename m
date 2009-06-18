Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 065246B005A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 21:24:57 -0400 (EDT)
Date: Thu, 18 Jun 2009 09:25:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class
	citizen
Message-ID: <20090618012532.GB19732@localhost>
References: <20090516090005.916779788@intel.com> <1242485776.32543.834.camel@laptop> <20090617141135.0d622bfe@jbarnes-g45>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090617141135.0d622bfe@jbarnes-g45>
Sender: owner-linux-mm@kvack.org
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 18, 2009 at 05:11:35AM +0800, Jesse Barnes wrote:
> On Sat, 16 May 2009 16:56:16 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Sat, 2009-05-16 at 17:00 +0800, Wu Fengguang wrote:
> > > Andrew,
> > > 
> > > This patchset makes mapped executable pages the first class citizen.
> > > This version has incorparated many valuable comments from people in
> > > the CC list, and runs OK on my desktop. Let's test it in your -mm?
> > 
> > Seems like a good set to me. Thanks for following this through Wu!
> 
> Now that this set has hit the mainline I just wanted to chime in and
> say this makes a big difference.  Under my current load (a parallel
> kernel build and virtualbox session the old kernel would have been
> totally unusable.  With Linus's current bits, things are much better
> (still a little sluggish with a big dd going on in the virtualbox, but
> actually usable).
> 
> Thanks!

Jesse, thank you for the feedback :)  And I'd like to credit Rik for
his patch on protecting active file LRU pages from being flushed by
streaming IO!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
