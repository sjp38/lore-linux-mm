Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 5708B6B00FD
	for <linux-mm@kvack.org>; Mon, 21 May 2012 16:54:45 -0400 (EDT)
Date: Mon, 21 May 2012 15:54:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] Common code 09/12] slabs: Extract a common function for
 kmem_cache_destroy
In-Reply-To: <4FBAA04D.7010007@parallels.com>
Message-ID: <alpine.DEB.2.00.1205211554110.10940@router.home>
References: <20120518161906.207356777@linux.com> <20120518161932.147485968@linux.com> <4FBA0C2D.3000101@parallels.com> <alpine.DEB.2.00.1205211312270.30649@router.home> <4FBA9536.1020502@parallels.com> <alpine.DEB.2.00.1205211430020.10940@router.home>
 <4FBAA04D.7010007@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On Tue, 22 May 2012, Glauber Costa wrote:

> On 05/21/2012 11:31 PM, Christoph Lameter wrote:
> > > >  But until then, people bisecting into this patch will find a broken
> > > state,
> > > >  right?
> > I thought this was about clumsiness not breakage. What is broken? Aliases
> > do not affect the call to __kmem_cache_shutdown. Its only called if there
> > are no aliases anymore.
> >
> >
> Well, that I missed - might be my fault. Can you point me to the exact point
> where you guarantee aliases are ignored, just so we're in the same page?

Look at the refcount checks. Aliases create additional refcounts.
kmem_cache_shutdown is only called if the refcount reaches zero.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
