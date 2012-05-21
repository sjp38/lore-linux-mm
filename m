Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 91F656B0083
	for <linux-mm@kvack.org>; Mon, 21 May 2012 15:31:59 -0400 (EDT)
Date: Mon, 21 May 2012 14:31:56 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] Common code 09/12] slabs: Extract a common function for
 kmem_cache_destroy
In-Reply-To: <4FBA9536.1020502@parallels.com>
Message-ID: <alpine.DEB.2.00.1205211430020.10940@router.home>
References: <20120518161906.207356777@linux.com> <20120518161932.147485968@linux.com> <4FBA0C2D.3000101@parallels.com> <alpine.DEB.2.00.1205211312270.30649@router.home> <4FBA9536.1020502@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On Mon, 21 May 2012, Glauber Costa wrote:

> On 05/21/2012 10:13 PM, Christoph Lameter wrote:
> > > So unless I am missing something, it seems to me the correct code would
> > > be:
> > > >
> > > >  s->refcount--;
> > > >  if (!s->refcount)
> > > >       return kmem_cache_close;
> > > >  return 0;
> > > >
> > > >  And while we're on that, that makes the sequence list_del() ->  if it
> > > fails ->
> > > >  list_add() in the common kmem_cache_destroy a bit clumsy. Aliases will
> > > be
> > > >  re-added to the list quite frequently. Not that it is a big problem,
> > > but
> > > >  still...
> > True but this is just an intermediate step. Ultimately the series will
> > move sysfs processing into slab_common.c and then this is going away.
> >
>
> But until then, people bisecting into this patch will find a broken state,
> right?

I thought this was about clumsiness not breakage. What is broken? Aliases
do not affect the call to __kmem_cache_shutdown. Its only called if there
are no aliases anymore.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
