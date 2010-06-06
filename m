Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 98FAB6B01AC
	for <linux-mm@kvack.org>; Sun,  6 Jun 2010 03:53:06 -0400 (EDT)
Date: Sun, 6 Jun 2010 17:52:58 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 0/2 RFC v3] Livelock avoidance for data integrity
 writeback
Message-ID: <20100606075258.GK26335@laptop>
References: <1275677231-15662-1-git-send-email-jack@suse.cz>
 <20100605011447.GF26335@laptop>
 <20100606040819.GA16293@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100606040819.GA16293@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, david@fromorbit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 06, 2010 at 12:08:19PM +0800, Wu Fengguang wrote:
> On Sat, Jun 05, 2010 at 11:14:47AM +1000, Nick Piggin wrote:
> > On Fri, Jun 04, 2010 at 08:47:09PM +0200, Jan Kara wrote:
> > > 
> > >   Hi,
> > > 
> > >   I've revived my patches to implement livelock avoidance for data integrity
> > > writes. Due to some concerns whether tagging of pages before writeout cannot
> > > be too costly to use for WB_SYNC_NONE mode (where we stop after nr_to_write
> > > pages) I've changed the patch to use page tagging only in WB_SYNC_ALL mode
> > > where we are sure that we write out all the tagged pages. Later, we can think
> > > about using tagging for livelock avoidance for WB_SYNC_NONE mode as well...
> > 
> > Hmm what concerns? Do you have any numbers?
> 
> sync() is performed in two stages: the WB_SYNC_NONE run and the
> WB_SYNC_ALL run. The WB_SYNC_NONE stage can still be livelocked.

By concerns, I mean Jan's _performance_ concerns. I would prefer to
minimise them, and then try to get an idea of the performance impact
of doing tagging unconditionally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
