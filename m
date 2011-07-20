Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 516CE6B007E
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 11:36:06 -0400 (EDT)
Date: Wed, 20 Jul 2011 10:36:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
In-Reply-To: <alpine.DEB.2.00.1107201653080.4921@tiger>
Message-ID: <alpine.DEB.2.00.1107201035360.1472@router.home>
References: <20110720121612.28888.38970.stgit@localhost6> <alpine.DEB.2.00.1107201611010.3528@tiger> <4E26D7EA.3000902@parallels.com> <alpine.DEB.2.00.1107201638520.4921@tiger> <4E26DD25.4010707@parallels.com> <alpine.DEB.2.00.1107201653080.4921@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, 20 Jul 2011, Pekka Enberg wrote:

> That's somewhat sad. I suppose I can just merge your patch unless other people
> object to it. I'd like a v2 with better changelog though.

Seems to be the simplest solution. Fix the changelog then add

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
