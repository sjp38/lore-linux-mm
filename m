Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id DB5106B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 08:10:11 -0400 (EDT)
Message-ID: <4FBCD328.6060406@parallels.com>
Date: Wed, 23 May 2012 16:08:08 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab+slob: dup name string
References: <1337613539-29108-1-git-send-email-glommer@parallels.com>  <alpine.DEB.2.00.1205212018230.13522@chino.kir.corp.google.com>  <alpine.DEB.2.00.1205220855470.17600@router.home>  <4FBBAE95.6080608@parallels.com>  <alpine.DEB.2.00.1205221216050.17721@router.home>  <alpine.DEB.2.00.1205221529340.18325@chino.kir.corp.google.com> <1337773595.3013.15.camel@dabdike.int.hansenpartnership.com>
In-Reply-To: <1337773595.3013.15.camel@dabdike.int.hansenpartnership.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/23/2012 03:46 PM, James Bottomley wrote:
>> We can't predict how slab will be extended in the future and this affects
>> >  anything created before g_cpucache_cpu<= EARLY.  This would introduce the
>> >  first problem with destroying such caches and is unnecessary if a
>> >  workaround exists.
> These problems seem to indicate that the slab behaviour: expecting the
> string to exist for the lifetime of the cache so there's no need to copy
> it might be better.
>
> This must be the behaviour all users of kmem_cache_create() expect
> anyway, since all enterprise distributions use slab and they're not
> getting bugs reported in this area.
>
> So, why not simply patch slab to rely on the string lifetime being the
> cache lifetime (or beyond) and therefore not having it take a copy?
>
You mean patch slub? slub is the one that takes a copy currently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
