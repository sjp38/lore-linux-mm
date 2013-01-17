Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id BD9DA6B0007
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 16:56:31 -0500 (EST)
Date: Thu, 17 Jan 2013 21:56:30 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] slub: Check for page NULL before doing the node_match
 check
In-Reply-To: <alpine.DEB.2.02.1301171547370.2774@gentwo.org>
Message-ID: <0000013c4a8363ed-ba83975a-7b62-4a9e-981b-8b44d8030431-000000@email.amazonses.com>
References: <1358446258.23211.32.camel@gandalf.local.home>  <1358447864.23211.34.camel@gandalf.local.home>  <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com> <1358458996.23211.46.camel@gandalf.local.home>
 <alpine.DEB.2.02.1301171547370.2774@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio R. Goncalves" <lgoncalv@redhat.com>

on Thu, 17 Jan 2013, Christoph Lameter wrote:

> Ditto which leaves us with:
>
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2013-01-17 15:49:57.417491975 -0600
> +++ linux/mm/slub.c	2013-01-17 15:50:49.010287150 -0600
> @@ -1993,8 +1993,9 @@ static inline void flush_slab(struct kme
>  	deactivate_slab(s, c->page, c->freelist);
>
>  	c->tid = next_tid(c->tid);
> -	c->page = NULL;
>  	c->freelist = NULL;
> +	barrier();
> +	c->page = NULL;
>  }

But the larger question is why is flush_slab() called with interrupts
enabled?

RT?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
