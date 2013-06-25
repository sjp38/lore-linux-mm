Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 9219E6B0032
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 22:29:23 -0400 (EDT)
Date: Tue, 25 Jun 2013 12:29:21 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130625022921.GQ29376@dastard>
References: <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
 <20130618062623.GA20528@localhost.localdomain>
 <20130619071346.GA9545@dhcp22.suse.cz>
 <20130619142801.GA21483@dhcp22.suse.cz>
 <20130620141136.GA3351@localhost.localdomain>
 <20130620151201.GD27196@dhcp22.suse.cz>
 <20130621090021.GB12424@dhcp22.suse.cz>
 <20130623115127.GA7986@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130623115127.GA7986@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sun, Jun 23, 2013 at 03:51:29PM +0400, Glauber Costa wrote:
> On Fri, Jun 21, 2013 at 11:00:21AM +0200, Michal Hocko wrote:
> > On Thu 20-06-13 17:12:01, Michal Hocko wrote:
> > > I am bisecting it again. It is quite tedious, though, because good case
> > > is hard to be sure about.
> > 
> > OK, so now I converged to 2d4fc052 (inode: convert inode lru list to generic lru
> > list code.) in my tree and I have double checked it matches what is in
> > the linux-next. This doesn't help much to pin point the issue I am
> > afraid :/
> > 
> Can you revert this patch (easiest way ATM is to rewind your tree to a point
> right before it) and apply the following patch?
> 
> As Dave has mentioned, it is very likely that this bug was already there, we
> were just not ever checking imbalances. The attached patch would tell us at
> least if the imbalance was there before. If this is the case, I would suggest
> turning the BUG condition into a WARN_ON_ONCE since we would be officially
> not introducing any regression. It is no less of a bug, though, and we should
> keep looking for it.

We probably should do that BUG->WARN change anyway. BUG_ON is pretty
obnoxious in places where we can probably continue on without much
impact....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
