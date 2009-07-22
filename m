Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E39D86B0133
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 19:58:42 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3BF8D82C5B7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 20:18:43 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LkccVd8jF3n1 for <linux-mm@kvack.org>;
	Wed, 22 Jul 2009 20:18:43 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 74BFF82C5BB
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 20:18:38 -0400 (EDT)
Date: Wed, 22 Jul 2009 19:58:34 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 5/4] mm: document is_page_cache_freeable()
In-Reply-To: <20090722221022.GA8667@cmpxchg.org>
Message-ID: <alpine.DEB.1.10.0907221957190.23591@gentwo.org>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org> <1248166594-8859-4-git-send-email-hannes@cmpxchg.org> <alpine.DEB.1.10.0907221220350.3588@gentwo.org> <20090722175031.GA3484@cmpxchg.org> <20090722175417.GA7059@cmpxchg.org>
 <alpine.DEB.1.10.0907221500440.29748@gentwo.org> <alpine.DEB.1.00.0907221447190.24706@mail.selltech.ca> <20090722221022.GA8667@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Li, Ming Chun" <macli@brc.ubc.ca>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Jul 2009, Johannes Weiner wrote:

> And I think in that context my comment should be obvious.  Do you need
> to know that the page cache is actually managed with radix trees at
> this point?

Its good to know where the pointer is that accounts for the
refcount. "pagecache" is a nebulous term.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
