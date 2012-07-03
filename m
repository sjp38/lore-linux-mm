Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id BCB116B0081
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:42:06 -0400 (EDT)
Date: Tue, 3 Jul 2012 13:42:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/4] don't do __ClearPageSlab before freeing slab page.
In-Reply-To: <4FE3830E.7050402@parallels.com>
Message-ID: <alpine.DEB.2.00.1207031341140.14703@router.home>
References: <1340225959-1966-1-git-send-email-glommer@parallels.com> <1340225959-1966-5-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206210103350.31077@chino.kir.corp.google.com> <4FE2D7B2.8060204@parallels.com> <4FE2FFDA.6000009@jp.fujitsu.com>
 <4FE3830E.7050402@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Suleiman Souhlal <suleiman@google.com>

On Fri, 22 Jun 2012, Glauber Costa wrote:

> How would the slab people feel, specially Christoph, about a simple change in
> the caches, replacing free_pages and alloc_pages by common functions that
> calls the memcg correspondents when needed ?

I believe that is one of the optionst that I proposed earlier.

> This would possibly render the __GFP_SLABMEMC not needed, since we'd have
> stable call sites for memcg to derive its context from.

Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
