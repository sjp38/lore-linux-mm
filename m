Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 4A28F6B0083
	for <linux-mm@kvack.org>; Thu, 17 May 2012 10:09:15 -0400 (EDT)
Date: Thu, 17 May 2012 09:09:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 8/9] slabs: list addition move to
 slab_common
In-Reply-To: <4FB4C755.6030106@parallels.com>
Message-ID: <alpine.DEB.2.00.1205170909040.5144@router.home>
References: <20120514201544.334122849@linux.com> <20120514201613.467708800@linux.com> <4FB37CC9.3060102@parallels.com> <alpine.DEB.2.00.1205160932201.25603@router.home> <4FB4C755.6030106@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On Thu, 17 May 2012, Glauber Costa wrote:

> On 05/16/2012 06:33 PM, Christoph Lameter wrote:
> > > >  Also, the only reasons it exists, seems to be to go around the fact
> > > that the
> > > >  slab already adds the kmalloc caches to a list in a slightly different
> > > way.
> > > >  And there has to be cleaner ways to achieve that.
> > The reason it exists is to distinguish the case of an alias creation from
> > a true kmem_cache instatiation. The alias does not need to be added to the
> > list of slabs.
> >
> Worth a comment, then, maybe ? It tricked me a bit

Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
