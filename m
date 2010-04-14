Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 181FF6B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 08:23:29 -0400 (EDT)
Received: by bwz2 with SMTP id 2so56870bwz.10
        for <linux-mm@kvack.org>; Wed, 14 Apr 2010 05:23:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100414091825.0bacfe48.kamezawa.hiroyu@jp.fujitsu.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <8b348d9cc1ea4960488b193b7e8378876918c0d4.1271171877.git.minchan.kim@gmail.com>
	 <20100414091825.0bacfe48.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 14 Apr 2010 15:23:27 +0300
Message-ID: <s2x84144f021004140523t3092f6cbge410ab4e15afac3e@mail.gmail.com>
Subject: Re: [PATCH 3/6] change alloc function in alloc_slab_page
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 3:18 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 14 Apr 2010 00:25:00 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> alloc_slab_page never calls alloc_pages_node with -1.
>> It means node's validity check is unnecessary.
>> So we can use alloc_pages_exact_node instead of alloc_pages_node.
>> It could avoid comparison and branch as 6484eb3e2a81807722 tried.
>>
>> Cc: Christoph Lameter <cl@linux-foundation.org>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Minchan, care to send a v2 with proper changelog and reviewed-by attributions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
