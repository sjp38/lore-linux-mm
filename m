Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id A1B926B0083
	for <linux-mm@kvack.org>; Thu, 17 May 2012 10:16:30 -0400 (EDT)
Date: Thu, 17 May 2012 09:16:28 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 5/9] slabs: Common definition for
 boot state of the slab allocators
In-Reply-To: <4FB5065E.8020702@parallels.com>
Message-ID: <alpine.DEB.2.00.1205170914340.5144@router.home>
References: <20120514201544.334122849@linux.com> <20120514201611.710540961@linux.com> <4FB36318.30600@parallels.com> <alpine.DEB.2.00.1205160928490.25603@router.home> <4FB4C71C.6040906@parallels.com> <alpine.DEB.2.00.1205170905350.5144@router.home>
 <4FB5065E.8020702@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On Thu, 17 May 2012, Glauber Costa wrote:

> > Why can this processing not be done when sysfs has just been initialized?
>
> If we can be 100 % sure that idr/ida is always initialized before sysfs, than
> yes, we can.

idr_init_cache() is run even before kmem_cache_init_late(). Have a look at
init/main.c. No need to muck with the bootup sequence.

> > The reason to use == is because we want things to happen only at a
> > particular stage of things. The == SYSFS means we will only do an action
> > if the slab system is fully functional. Such things will have to be
> > reevaluated if the number of states change.
>
> Yes, but you are actually arguing in my favor. "fully functional" means >=
> SYSFS, not == SYSFS.

That is only true if you add another state.

> If for whatever reordering people may decide doing another state is added, or
> this function is called later, that will fail

Then the assumptions that SYSFS is the final state is no longer true and
therefore the code needs to be inspected if this change affects anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
