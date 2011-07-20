Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C03216B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 11:35:02 -0400 (EDT)
Date: Wed, 20 Jul 2011 10:34:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
In-Reply-To: <1311174562.2338.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Message-ID: <alpine.DEB.2.00.1107201033080.1472@router.home>
References: <20110720121612.28888.38970.stgit@localhost6>  <alpine.DEB.2.00.1107201611010.3528@tiger> <20110720134342.GK5349@suse.de>  <alpine.DEB.2.00.1107200854390.32737@router.home>  <1311170893.2338.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <alpine.DEB.2.00.1107200950270.1472@router.home> <1311174562.2338.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

On Wed, 20 Jul 2011, Eric Dumazet wrote:

> [PATCH] slab: remove one NR_CPUS dependency

Ok simple enough.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
