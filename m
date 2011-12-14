Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id ABA1F6B0308
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 13:26:32 -0500 (EST)
Date: Wed, 14 Dec 2011 12:26:29 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: RE: [PATCH 1/3] slub: set a criteria for slub node partial adding
In-Reply-To: <1323883989.2334.68.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Message-ID: <alpine.DEB.2.00.1112141223190.16534@router.home>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>   <alpine.DEB.2.00.1112020842280.10975@router.home>   <1323419402.16790.6105.camel@debian>   <alpine.DEB.2.00.1112090203370.12604@chino.kir.corp.google.com>  
 <6E3BC7F7C9A4BF4286DD4C043110F30B67236EED18@shsmsx502.ccr.corp.intel.com>   <alpine.DEB.2.00.1112131734070.8593@chino.kir.corp.google.com>   <alpine.DEB.2.00.1112131835100.31514@chino.kir.corp.google.com>   <1323842761.16790.8295.camel@debian>  
 <1323845054.2846.18.camel@edumazet-laptop>  <1323845812.16790.8307.camel@debian>  <alpine.DEB.2.00.1112140853540.12235@router.home> <1323883989.2334.68.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Alex,Shi" <alex.shi@intel.com>, David Rientjes <rientjes@google.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 14 Dec 2011, Eric Dumazet wrote:

> > Many people have done patchsets like this.
>
> Things changed a lot recently. There is room for improvements.
>
> At least we can exchange ideas _before_ coding a new patchset ?

Sure but I hope we do not simply rehash what has been said before and
recode what others have code in years past.

> > There are various permutations
> > on SL?B (I dont remember them all SLEB, SLXB, SLQB etc) that have been
> > proposed over the years. Caches tend to grow and get rather numerous (see
> > SLAB) and the design of SLUB was to counter that. There is a reason it was
> > called SLUB. The U stands for Unqueued and was intended to avoid the
> > excessive caching problems that I ended up when reworking SLAB for NUMA
> > support.
>
> Current 'one active slab' per cpu is a one level cache.
>
> It really is a _queue_ containing a fair amount of objects.

In some sense you are right. It is a set of objects linked together. That
can be called a queue and it has certain cache hot effects. It is not a
qeueue in the SLAB sense meaning a configurable array of pointers.

> My initial idea would be to use a cache of 4 slots per cpu, but be able
> to queue many objects per slot, if they all belong to same slab/page.

Nick did that. Please read up on his work. I think it was named SLQB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
