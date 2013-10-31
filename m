Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f80.google.com (mail-qe0-f80.google.com [209.85.128.80])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7836B0038
	for <linux-mm@kvack.org>; Fri,  1 Nov 2013 10:09:41 -0400 (EDT)
Received: by mail-qe0-f80.google.com with SMTP id b4so57096qen.3
        for <linux-mm@kvack.org>; Fri, 01 Nov 2013 07:09:41 -0700 (PDT)
Received: from psmtp.com ([74.125.245.130])
        by mx.google.com with SMTP id ph6si2076124pbb.307.2013.10.31.07.40.42
        for <linux-mm@kvack.org>;
        Thu, 31 Oct 2013 07:40:43 -0700 (PDT)
Date: Thu, 31 Oct 2013 10:37:58 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: + mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch added to
 -mm tree
Message-ID: <20131031143758.GE14054@cmpxchg.org>
References: <52718460.4+rPcYBdFtC2v3uh%akpm@linux-foundation.org>
 <20131031085017.GB13144@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131031085017.GB13144@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 31, 2013 at 09:50:17AM +0100, Michal Hocko wrote:
> On Wed 30-10-13 15:12:48, Andrew Morton wrote:
> > Subject: + mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch added to -mm tree
> > To: hannes@cmpxchg.org,mhocko@suse.cz
> > From: akpm@linux-foundation.org
> > Date: Wed, 30 Oct 2013 15:12:48 -0700
> > 
> > 
> > The patch titled
> >      Subject: mm: memcg: lockdep annotation for memcg OOM lock
> > has been added to the -mm tree.  Its filename is
> >      mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch
> > 
> > This patch should soon appear at
> >     http://ozlabs.org/~akpm/mmots/broken-out/mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch
> > and later at
> >     http://ozlabs.org/~akpm/mmotm/broken-out/mm-memcg-lockdep-annotation-for-memcg-oom-lock.patch
> > 
> > Before you just go and hit "reply", please:
> >    a) Consider who else should be cc'ed
> >    b) Prefer to cc a suitable mailing list as well
> >    c) Ideally: find the original patch on the mailing list and do a
> >       reply-to-all to that, adding suitable additional cc's
> > 
> > *** Remember to use Documentation/SubmitChecklist when testing your code ***
> > 
> > The -mm tree is included into linux-next and is updated
> > there every 3-4 working days
> > 
> > ------------------------------------------------------
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Subject: mm: memcg: lockdep annotation for memcg OOM lock
> > 
> > The memcg OOM lock is a mutex-type lock that is open-coded due to memcg's
> > special needs.  Add annotations for lockdep coverage.
> 
> I am not sure what this gives us to be honest. AA and AB-BA deadlocks
> are impossible due to nature of the lock (it is trylock so we never
> block on it).

It's not an actual trylock, because we loop around it.  If it fails,
we wait for the unlock, restart the fault, and try again.  That's a
LOCK operation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
