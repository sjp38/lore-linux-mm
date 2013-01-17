Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 06F536B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 16:44:23 -0500 (EST)
Message-ID: <1358459061.23211.47.camel@gandalf.local.home>
Subject: Re: [RFC][PATCH] slub: Check for page NULL before doing the
 node_match check
From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 17 Jan 2013 16:44:21 -0500
In-Reply-To: <1358458583.11051.7.camel@edumazet-glaptop>
References: <1358446258.23211.32.camel@gandalf.local.home>
	 <1358447864.23211.34.camel@gandalf.local.home>
	 <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com>
	 <1358458583.11051.7.camel@edumazet-glaptop>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio
 R. Goncalves" <lgoncalv@redhat.com>

On Thu, 2013-01-17 at 13:36 -0800, Eric Dumazet wrote:

> > Index: linux/mm/slub.c
> > ===================================================================
> > --- linux.orig/mm/slub.c	2013-01-15 10:42:08.490183607 -0600
> > +++ linux/mm/slub.c	2013-01-17 15:27:48.973051155 -0600
> > @@ -1993,8 +1993,8 @@ static inline void flush_slab(struct kme
> >  	deactivate_slab(s, c->page, c->freelist);
> > 
> >  	c->tid = next_tid(c->tid);
> > -	c->page = NULL;
> >  	c->freelist = NULL;
> > +	c->page = NULL;
> >  }
> > 
> >  /*
> > @@ -2227,8 +2227,8 @@ redo:
> >  	if (unlikely(!node_match(page, node))) {
> >  		stat(s, ALLOC_NODE_MISMATCH);
> >  		deactivate_slab(s, page, c->freelist);
> > -		c->page = NULL;
> >  		c->freelist = NULL;
> > +		c->page = NULL;
> >  		goto new_slab;
> >  	}
> > 
> > @@ -2239,8 +2239,8 @@ redo:
> >  	 */
> >  	if (unlikely(!pfmemalloc_match(page, gfpflags))) {
> >  		deactivate_slab(s, page, c->freelist);
> > -		c->page = NULL;
> >  		c->freelist = NULL;
> > +		c->page = NULL;
> >  		goto new_slab;
> >  	}
> > 
> 
> Without appropriate barriers, this change is a shoot in the dark.

Totally agree.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
