Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BE4EA8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 08:27:54 -0400 (EDT)
Date: Thu, 31 Mar 2011 14:27:47 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf] [LSF][MM] rough agenda for memcg.
Message-ID: <20110331122747.GC21524@quack.suse.cz>
References: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTikLPTr46S6k5LaZ3sfsXG=PrQNvGA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTikLPTr46S6k5LaZ3sfsXG=PrQNvGA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lsf@lists.linux-foundation.org, linux-mm@kvack.org

On Wed 30-03-11 22:52:49, Greg Thelen wrote:
> On Wed, Mar 30, 2011 at 7:01 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > I'd like to sort out topics before going. Please fix if I don't catch enough.
> >
> > mentiont to 1. later...
> >
> > Main topics on 2. Memcg Dirty Limit and writeback ....is
> >
> >  a) How to implement per-memcg dirty inode finding method (list) and
> >    how flusher threads handle memcg.
> 
> I have some very rough code implementing the ideas discussed in
> http://thread.gmane.org/gmane.linux.kernel.mm/59707
> Unfortunately, I do not yet have good patches, but maybe an RFC series
> soon.  I can provide update on the direction I am thinking.
> 
> >  b) Hot to interact with IO-Less dirty page reclaim.
> >    IIUC, if memcg doesn't handle this correctly, OOM happens.
> 
> The last posted memcg dirty writeback patches were based on -mm at the
> time, which did not have IO-less balance_dirty_pages.  I have an
> approach which I _think_ will be compatible with IO-less
> balance_dirty_pages(), but I need to talk with some writeback guys to
> confirm.  Seeing the Writeback talk Mon 9:30am should be very useful
> for me.
> 
> >  Greg, do we need to have a shared session with I/O guys ?
> >  If needed, current schedule is O.K. ?
> 
> We can contact any interested writeback guys to see if they want to
> attend memcg-writeback discussion.  We might be able to defer this
> detail until Mon morning.
  Yes, I plan to take part in this discussion. If this would be joint
session with fs people (which kind of makes sense) it's simpler for
me but I can surely handle if it isn't :).

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
