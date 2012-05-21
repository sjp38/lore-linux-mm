Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 1899D6B0044
	for <linux-mm@kvack.org>; Mon, 21 May 2012 09:51:19 -0400 (EDT)
Date: Mon, 21 May 2012 08:51:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] Common code 00/12] Sl[auo]b: Common functionality V2
In-Reply-To: <4FBA0D25.8040203@parallels.com>
Message-ID: <alpine.DEB.2.00.1205210850380.27592@router.home>
References: <20120518161906.207356777@linux.com> <4FBA0D25.8040203@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

On Mon, 21 May 2012, Glauber Costa wrote:

> While we're at it, can one of my patches for consistent name string handling
> among caches be applied?
>
> Once you guys reach a decision about what is the best behavior: strdup'ing it
> in all caches, or not strduping it for the slub, I can provide an updated
> patch that also updates the slob accordingly.

strduping is the safest approach. If slabs keep a pointer to string data
around then slabs also need their private copy.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
