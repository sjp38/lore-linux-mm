Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9FEE16B0034
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 04:20:12 -0400 (EDT)
From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: possible slab deadlock while doing ifenslave
Date: Thu, 13 Oct 2011 10:19:58 +0200
References: <201110121019.53100.hans@schillstrom.com> <alpine.DEB.2.00.1110121333560.7646@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1110121333560.7646@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201110131019.58397.hans@schillstrom.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org

On Wednesday, October 12, 2011 22:35:51 David Rientjes wrote:
> On Wed, 12 Oct 2011, Hans Schillstrom wrote:
> 
> > Hello,
> > I got this when I was testing a VLAN patch i.e. using Dave Millers net-next from today.
> > When doing this on a single core i686 I got the warning every time,
> > however ifenslave is not hanging it's just a warning
> > Have not been testing this on a multicore jet.
> > 
> > There is no warnings with a 3.0.4 kernel.
> > 
> > Is this a known warning ?
> > 
> > ~ # ifenslave bond0 eth1 eth2
> > 
> > =============================================
> > [ INFO: possible recursive locking detected ]
> > 3.1.0-rc9+ #3
> > ---------------------------------------------
> > ifenslave/749 is trying to acquire lock:
> >  (&(&parent->list_lock)->rlock){-.-...}, at: [<c14234a0>] cache_flusharray+0x41/0xdb
> > 
> > but task is already holding lock:
> >  (&(&parent->list_lock)->rlock){-.-...}, at: [<c14234a0>] cache_flusharray+0x41/0xdb
> > 
> 
> Hmm, the only candidate that I can see that may have caused this is 
> 83835b3d9aec ("slab, lockdep: Annotate slab -> rcu -> debug_object -> 
> slab").  Could you try reverting that patch in your local tree and seeing 
> if it helps?
> 

That was not our candidate ...
i.e. same results

Thanks
Hans

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
