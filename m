Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9E43C8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 15:08:12 -0400 (EDT)
Received: by fxm18 with SMTP id 18so49142fxm.14
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:08:10 -0700 (PDT)
Date: Thu, 21 Apr 2011 21:08:07 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110421190807.GK15988@htj.dyndns.org>
References: <alpine.DEB.2.00.1104151440070.8055@router.home>
 <20110415235222.GA18694@mtj.dyndns.org>
 <alpine.DEB.2.00.1104180930580.23207@router.home>
 <20110421144300.GA22898@htj.dyndns.org>
 <20110421145837.GB22898@htj.dyndns.org>
 <alpine.DEB.2.00.1104211243350.5741@router.home>
 <20110421180159.GF15988@htj.dyndns.org>
 <alpine.DEB.2.00.1104211308300.5741@router.home>
 <20110421183727.GG15988@htj.dyndns.org>
 <alpine.DEB.2.00.1104211350310.5741@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104211350310.5741@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, shaohua.li@intel.com

Hello,

On Thu, Apr 21, 2011 at 01:54:51PM -0500, Christoph Lameter wrote:
> Well again there is general fuzziness here and we are trying to make the
> best of it without compromising performance too much. Shaohua's numbers
> indicate that removing the lock is very advantagous. More over we do the
> same thing in other places.

The problem with Shaohua's numbers is that it's a pessimistic test
case with too low batch count.  If an optimization improves such
situations without compromising funcitionality or introducing too much
complexity, sure, why not?  But I'm not sure that's the case here.

> Actually its good to make the code paths for vmstats and percpu counters
> similar. That is what this does too.
> 
> Preempt enable/disable in any function that is supposedly fast is
> something bad that can be avoided with these patches as well.

If you really wanna push the _sum() fuziness change, the only way to
do that would be auditing all the current users and making sure that
it won't affect any of them.  It really doesn't matter what vmstat is
doing.  They're different users.

And, no matter what, that's a separate issue from the this_cpu hot
path optimizations and should be done separately.  So, _please_ update
this_cpu patch so that it doesn't change the slow path semantics.

Thank you.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
