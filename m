Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 53E536B0092
	for <linux-mm@kvack.org>; Wed, 23 May 2012 07:46:40 -0400 (EDT)
Message-ID: <1337773595.3013.15.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [PATCH] slab+slob: dup name string
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 23 May 2012 12:46:35 +0100
In-Reply-To: <alpine.DEB.2.00.1205221529340.18325@chino.kir.corp.google.com>
References: <1337613539-29108-1-git-send-email-glommer@parallels.com>
	 <alpine.DEB.2.00.1205212018230.13522@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1205220855470.17600@router.home>
	 <4FBBAE95.6080608@parallels.com>
	 <alpine.DEB.2.00.1205221216050.17721@router.home>
	 <alpine.DEB.2.00.1205221529340.18325@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 2012-05-22 at 15:31 -0700, David Rientjes wrote:
> On Tue, 22 May 2012, Christoph Lameter wrote:
> 
> > > I think that's precisely David's point: that we might want to destroy them
> > > eventually.
> > 
> > Cannot imagine why.
> > 
> 
> We can't predict how slab will be extended in the future and this affects 
> anything created before g_cpucache_cpu <= EARLY.  This would introduce the 
> first problem with destroying such caches and is unnecessary if a 
> workaround exists.

These problems seem to indicate that the slab behaviour: expecting the
string to exist for the lifetime of the cache so there's no need to copy
it might be better.

This must be the behaviour all users of kmem_cache_create() expect
anyway, since all enterprise distributions use slab and they're not
getting bugs reported in this area.

So, why not simply patch slab to rely on the string lifetime being the
cache lifetime (or beyond) and therefore not having it take a copy?

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
