Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AC9BD6B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 14:49:51 -0400 (EDT)
Message-ID: <4BCB5448.3010209@cs.helsinki.fi>
Date: Sun, 18 Apr 2010 21:49:44 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] change alloc function in alloc_slab_page
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>  <8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com>  <20100414091825.0bacfe48.kamezawa.hiroyu@jp.fujitsu.com> <s2x84144f021004140523t3092f6cbge410ab4e15afac3e@mail.gmail.com> <alpine.DEB.2.00.1004161109070.7710@router.home>
In-Reply-To: <alpine.DEB.2.00.1004161109070.7710@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 14 Apr 2010, Pekka Enberg wrote:
> 
>> Minchan, care to send a v2 with proper changelog and reviewed-by attributions?
> 
> Still wondering what the big deal about alloc_pages_node_exact is. Its not
> exact since we can fall back to another node. It is better to clarify the
> API for alloc_pages_node and forbid / clarify the use of -1.

Minchan's patch is a continuation of this patch:

http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commit;h=6484eb3e2a81807722

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
