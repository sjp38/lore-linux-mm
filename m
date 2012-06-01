Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id EAB706B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 02:39:25 -0400 (EDT)
Received: by lahi5 with SMTP id i5so1742801lah.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 23:39:23 -0700 (PDT)
Date: Fri, 1 Jun 2012 09:39:20 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] slub: change cmpxchg_double_slab in get_freelist() to
 __cmpxchg_double_slab
In-Reply-To: <alpine.DEB.2.00.1205311351540.2764@chino.kir.corp.google.com>
Message-ID: <alpine.LFD.2.02.1206010934460.2163@tux.localdomain>
References: <1336665378-2967-1-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1205142332060.19403@chino.kir.corp.google.com> <alpine.DEB.2.00.1205311351540.2764@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On Mon, 14 May 2012, David Rientjes wrote:
> > On Fri, 11 May 2012, Joonsoo Kim wrote:
> > 
> > > get_freelist() is only called by __slab_alloc with interrupt disabled,
> > > so __cmpxchg_double_slab is suitable.
> > > 
> > > Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> > 
> > Acked-by: David Rientjes <rientjes@google.com>

On Thu, 31 May 2012, David Rientjes wrote:
> Pekka, did you want to pick this up so it can get into linux-next?

We now made get_freelist() *require* interrupts to be disabled which 
deserves a comment, no?

Also, what do we gain from patches like this? It's somewhat 
counterintuitive that we have a function with "cmpxchg" in it which is not 
always atomic (i.e. you need to have interrupts disabled).

IIRC, there was even a long rant about this by Linus but I'm unable to 
find it in my email archives.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
