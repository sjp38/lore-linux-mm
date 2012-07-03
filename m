Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id D2BD16B007D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:40:47 -0400 (EDT)
Date: Tue, 3 Jul 2012 13:40:44 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/4] don't do __ClearPageSlab before freeing slab page.
In-Reply-To: <4FE2D7B2.8060204@parallels.com>
Message-ID: <alpine.DEB.2.00.1207031339470.14703@router.home>
References: <1340225959-1966-1-git-send-email-glommer@parallels.com> <1340225959-1966-5-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206210103350.31077@chino.kir.corp.google.com> <4FE2D7B2.8060204@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Suleiman Souhlal <suleiman@google.com>

On Thu, 21 Jun 2012, Glauber Costa wrote:

> Well, if the requirement is that we must handle this from the page allocator,
> how else should I know if I must call the corresponding free functions ?

Is there such a requirement? I believe I was talking about a wrapper that
accounts for page allocator requests.

> Also note that other bits are tested inside the page allocator as well, such
> as MLock.

Yea so we could do this but doing so requires agreement with the people
involved in page allocator development.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
