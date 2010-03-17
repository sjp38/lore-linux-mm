Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 29CD66B0118
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:41:52 -0400 (EDT)
Date: Wed, 17 Mar 2010 11:41:10 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
In-Reply-To: <20100317121551.b619f55b.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003171139280.27268@router.home>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie> <1268412087-13536-3-git-send-email-mel@csn.ul.ie> <28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com> <20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com> <20100315112829.GI18274@csn.ul.ie>
 <1268657329.1889.4.camel@barrios-desktop> <20100315142124.GL18274@csn.ul.ie> <20100316084934.3798576c.kamezawa.hiroyu@jp.fujitsu.com> <20100317111234.d224f3fd.kamezawa.hiroyu@jp.fujitsu.com> <28c262361003162000w34cc13ecnbd32840a0df80f95@mail.gmail.com>
 <20100317121551.b619f55b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Mar 2010, KAMEZAWA Hiroyuki wrote:

> Ah, my point is "how use-after-free is detected ?"

The slab layers do not check for use after free conditions if
SLAB_DESTROY_BY_RCU is set. It is legal to access the object after a
kfree() etc as long as the RCU period has not passed.

> Then, my question is
> "Does use-after-free check for SLAB_DESTROY_BY_RCU work correctly ?"

Use after free checks are not performed for SLAB_DESTROY_BY_RCU slabs.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
