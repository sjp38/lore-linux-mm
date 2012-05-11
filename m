Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 134698D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 11:07:52 -0400 (EDT)
Date: Fri, 11 May 2012 16:07:47 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/17] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Message-ID: <20120511150747.GU11435@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
 <1336657510-24378-11-git-send-email-mgorman@suse.de>
 <20120511.005740.210437168371869566.davem@davemloft.net>
 <20120511143218.GS11435@suse.de>
 <1336747350.1017.22.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1336747350.1017.22.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, michaelc@cs.wisc.edu, emunson@mgebm.net

On Fri, May 11, 2012 at 04:42:30PM +0200, Peter Zijlstra wrote:
> On Fri, 2012-05-11 at 15:32 +0100, Mel Gorman wrote:
> > > > +extern atomic_t memalloc_socks;
> > > > +static inline int sk_memalloc_socks(void)
> > > > +{
> > > > +   return atomic_read(&memalloc_socks);
> > > > +}
> > > 
> > > Please change this to be a static branch.
> > > 
> > 
> > Will do. I renamed memalloc_socks to sk_memalloc_socks, made it a int as
> > atomics are unnecessary and I check it directly in a branch instead of a
> > static inline. It should be relatively easy for the branch predictor. 
> 
> David means you to use include/linux/jump_label.h.
> 

Ah, that makes a whole lot more sense. Thanks for the clarification.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
