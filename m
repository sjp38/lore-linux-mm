Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id BDC696B0092
	for <linux-mm@kvack.org>; Wed, 23 May 2012 05:27:26 -0400 (EDT)
Message-ID: <4FBCAD03.5010106@parallels.com>
Date: Wed, 23 May 2012 13:25:23 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] slab+slob: dup name string
References: <1337680298-11929-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205220857380.17600@router.home> <alpine.DEB.2.00.1205222048380.28165@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1205222048380.28165@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/23/2012 07:55 AM, David Rientjes wrote:
> I hate consistency patches like this because it could potentially fail a
> kmem_cache_create() from a sufficiently long cache name when it wouldn't
> have before, but I'm not really concerned since kmem_cache_create() will
> naturally be followed by kmem_cache_alloc() which is more likely to cause
> the oom anyway.  But it's just another waste of memory for consistency
> sake.
>
> This is much easier to do, just statically allocate the const char *'s
> needed for the boot caches and then set their ->name's manually in
> kmem_cache_init() and then avoid the kfree() in kmem_cache_destroy() if
> the name is between&boot_cache_name[0] and&boot_cache_name[n].

That can be done.

I'll also revisit my memcg patches to see if I can rework it so it 
doesn't care about this particular behavior. We're having a surprisingly 
difficult time reaching consensus on this, so maybe it would be better 
left untouched (if there is a way that makes sense to)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
