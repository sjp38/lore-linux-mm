Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id EE3C06B0036
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 11:36:31 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id p10so2519674pdj.25
        for <linux-mm@kvack.org>; Thu, 31 Oct 2013 08:36:31 -0700 (PDT)
Received: from psmtp.com ([74.125.245.153])
        by mx.google.com with SMTP id dj3si2252360pbc.70.2013.10.31.08.36.28
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 08:36:30 -0700 (PDT)
Date: Thu, 31 Oct 2013 16:36:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch added to
 -mm tree
Message-ID: <20131031153624.GA32240@dhcp22.suse.cz>
References: <52718460.4+rPcYBdFtC2v3uh%akpm@linux-foundation.org>
 <20131031085017.GB13144@dhcp22.suse.cz>
 <20131031143758.GE14054@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131031143758.GE14054@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Thu 31-10-13 10:37:58, Johannes Weiner wrote:
> On Thu, Oct 31, 2013 at 09:50:17AM +0100, Michal Hocko wrote:
> > On Wed 30-10-13 15:12:48, Andrew Morton wrote:
[...]
> > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > Subject: mm: memcg: lockdep annotation for memcg OOM lock
> > > 
> > > The memcg OOM lock is a mutex-type lock that is open-coded due to memcg's
> > > special needs.  Add annotations for lockdep coverage.
> > 
> > I am not sure what this gives us to be honest. AA and AB-BA deadlocks
> > are impossible due to nature of the lock (it is trylock so we never
> > block on it).
> 
> It's not an actual trylock, because we loop around it.  If it fails,
> we wait for the unlock, restart the fault, and try again.  That's a
> LOCK operation.

OK, I have to revisit the shole series. Do you plan to post it anytime
soon? Or where can I find the latest version?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
