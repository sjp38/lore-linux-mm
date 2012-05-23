Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 623136B0081
	for <linux-mm@kvack.org>; Wed, 23 May 2012 09:48:51 -0400 (EDT)
Date: Wed, 23 May 2012 08:48:48 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab+slob: dup name string
In-Reply-To: <alpine.DEB.2.00.1205221529340.18325@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1205230847580.29893@router.home>
References: <1337613539-29108-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205212018230.13522@chino.kir.corp.google.com> <alpine.DEB.2.00.1205220855470.17600@router.home> <4FBBAE95.6080608@parallels.com> <alpine.DEB.2.00.1205221216050.17721@router.home>
 <alpine.DEB.2.00.1205221529340.18325@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 22 May 2012, David Rientjes wrote:

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

Changes to the very early bootstrap code of slab allocators are rare and
the code there is dicey anyways. It is much more risky to add additional
allocations of varying length at that stage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
