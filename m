Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 0C7176B002C
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 01:16:20 -0500 (EST)
Date: Wed, 22 Feb 2012 07:16:18 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 00/22] mm: lru_lock splitting
Message-ID: <20120222061618.GT7703@one.firstfloor.org>
References: <20120220171138.22196.65847.stgit@zurg> <m2boor33g8.fsf@firstfloor.org> <4F447904.90500@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F447904.90500@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, tim.c.chen@linux.intel.com

On Wed, Feb 22, 2012 at 09:11:32AM +0400, Konstantin Khlebnikov wrote:
> Andi Kleen wrote:
> >Konstantin Khlebnikov<khlebnikov@openvz.org>  writes:
> >
> >Konstantin,
> >
> >>There complete patch-set with my lru_lock splitting
> >>plus all related preparations and cleanups rebased to next-20120210
> >
> >On large systems we're also seeing lock contention on the lru_lock
> >without using memcgs. Any thoughts how this could be extended for this
> >situation too?
> 
> We can split lru_lock by pfn-based interleaving.
> After all these cleanups it is very easy. I already have patch for this.

Cool. If you send it can try it out on a large system.

This would split the LRU by pfn too, correct?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
