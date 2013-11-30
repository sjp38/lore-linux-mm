Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id CC8836B0035
	for <linux-mm@kvack.org>; Fri, 29 Nov 2013 19:50:08 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so14520523pdj.2
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 16:50:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id dk5si41035505pbc.106.2013.11.29.16.50.06
        for <linux-mm@kvack.org>;
        Fri, 29 Nov 2013 16:50:07 -0800 (PST)
Date: Fri, 29 Nov 2013 16:51:00 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [merged]
 mm-memcg-handle-non-error-oom-situations-more-gracefully.patch removed from
 -mm tree
Message-ID: <20131130005100.GA8387@kroah.com>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org>
 <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com>
 <20131127233353.GH3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com>
 <20131128021809.GI3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271826001.5120@chino.kir.corp.google.com>
 <20131128031313.GK3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271914460.5120@chino.kir.corp.google.com>
 <20131128035218.GM3556@cmpxchg.org>
 <alpine.DEB.2.02.1311291546370.22413@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311291546370.22413@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, azurit@pobox.sk, mm-commits@vger.kernel.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Nov 29, 2013 at 04:00:09PM -0800, David Rientjes wrote:
> On Wed, 27 Nov 2013, Johannes Weiner wrote:
> 
> > > None that I am currently aware of, I'll continue to try them out.  I'd 
> > > suggest just dropping the stable@kernel.org from the whole series though 
> > > unless there is another report of such a problem that people are running 
> > > into.
> > 
> > The series has long been merged, how do we drop stable@kernel.org from
> > it?
> > 
> 
> You said you have informed stable to not merge these patches until further 
> notice, I'd suggest simply avoid ever merging the whole series into a 
> stable kernel since the problem isn't serious enough.  Marking changes 
> that do "goto nomem" seem fine to mark for stable, though.

I'm lost.  These patches are in 3.12, so how can they not be "in
stable"?

What exactly do you want me to do here?

totally confused,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
