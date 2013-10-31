Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id AA9596B0038
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 12:40:03 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id xb4so3035331pbc.36
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 09:40:03 -0700 (PDT)
Received: from psmtp.com ([74.125.245.123])
        by mx.google.com with SMTP id kk1si2395463pbc.124.2013.10.31.09.40.00
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 09:40:01 -0700 (PDT)
Date: Thu, 31 Oct 2013 17:39:56 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch added to
 -mm tree
Message-ID: <20131031163956.GB32240@dhcp22.suse.cz>
References: <52718460.4+rPcYBdFtC2v3uh%akpm@linux-foundation.org>
 <20131031085017.GB13144@dhcp22.suse.cz>
 <20131031143758.GE14054@cmpxchg.org>
 <20131031153624.GA32240@dhcp22.suse.cz>
 <20131031162815.GG14054@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131031162815.GG14054@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Thu 31-10-13 12:28:15, Johannes Weiner wrote:
> On Thu, Oct 31, 2013 at 04:36:24PM +0100, Michal Hocko wrote:
> > On Thu 31-10-13 10:37:58, Johannes Weiner wrote:
> > > On Thu, Oct 31, 2013 at 09:50:17AM +0100, Michal Hocko wrote:
> > > > On Wed 30-10-13 15:12:48, Andrew Morton wrote:
> > [...]
> > > > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > > > Subject: mm: memcg: lockdep annotation for memcg OOM lock
> > > > > 
> > > > > The memcg OOM lock is a mutex-type lock that is open-coded due to memcg's
> > > > > special needs.  Add annotations for lockdep coverage.
> > > > 
> > > > I am not sure what this gives us to be honest. AA and AB-BA deadlocks
> > > > are impossible due to nature of the lock (it is trylock so we never
> > > > block on it).
> > > 
> > > It's not an actual trylock, because we loop around it.  If it fails,
> > > we wait for the unlock, restart the fault, and try again.  That's a
> > > LOCK operation.
> > 
> > OK, I have to revisit the shole series. Do you plan to post it anytime
> > soon? Or where can I find the latest version?
> 
> It's all upstream (except for these fixups).  So mmotm would be the
> best reference I guess.

OK, it will still take me a bit to get in sync...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
