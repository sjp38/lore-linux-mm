Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2AFB56B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 10:05:49 -0400 (EDT)
Date: Fri, 3 Jun 2011 09:05:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] SLAB: Record actual last user of freed objects.
In-Reply-To: <alpine.DEB.2.00.1106021011510.18350@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1106030904320.27151@router.home>
References: <1306999002-29738-1-git-send-email-ssouhlal@FreeBSD.org> <alpine.DEB.2.00.1106021011510.18350@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, penberg@kernel.org, suleiman@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com

On Thu, 2 Jun 2011, David Rientjes wrote:

> On Thu, 2 Jun 2011, Suleiman Souhlal wrote:
>
> > Currently, when using CONFIG_DEBUG_SLAB, we put in kfree() or
> > kmem_cache_free() as the last user of free objects, which is not
> > very useful, so change it to the caller of those functions instead.
> >
> > Signed-off-by: Suleiman Souhlal <suleiman@google.com>
>
> Acked-by: David Rientjes <rientjes@google.com>

Well note that this increases the overhead of a hot code path. But slub
does the same

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
