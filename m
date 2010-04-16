Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 030EF6B0200
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 12:13:40 -0400 (EDT)
Date: Fri, 16 Apr 2010 11:10:01 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/6] change alloc function in alloc_slab_page
In-Reply-To: <s2x84144f021004140523t3092f6cbge410ab4e15afac3e@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1004161109070.7710@router.home>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>  <8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com>  <20100414091825.0bacfe48.kamezawa.hiroyu@jp.fujitsu.com>
 <s2x84144f021004140523t3092f6cbge410ab4e15afac3e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Apr 2010, Pekka Enberg wrote:

> Minchan, care to send a v2 with proper changelog and reviewed-by attributions?

Still wondering what the big deal about alloc_pages_node_exact is. Its not
exact since we can fall back to another node. It is better to clarify the
API for alloc_pages_node and forbid / clarify the use of -1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
