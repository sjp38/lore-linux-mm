Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 33E636B014A
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 06:34:56 -0400 (EDT)
Date: Wed, 26 Aug 2009 12:33:58 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH mmotm] mm: introduce page_lru_base_type fix
Message-ID: <20090826103358.GA26897@cmpxchg.org>
References: <Pine.LNX.4.64.0908261050080.18633@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908261050080.18633@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 26, 2009 at 10:53:47AM +0100, Hugh Dickins wrote:
> My usual tmpfs swapping loads on recent mmotms have oddly
> aroused the OOM killer after an hour or two.  Bisection led to
> mm-return-boolean-from-page_is_file_cache.patch, but really it's
> the prior mm-introduce-page_lru_base_type.patch that's at fault.
> 
> It converted page_lru() to use page_lru_base_type(), but forgot
> to convert del_page_from_lru() - which then decremented the wrong
> stats once page_is_file_cache() was changed to a boolean.

Ouch, sorry.  Thanks for your fix.

> Fix that, move page_lru_base_type() before del_page_from_lru(),
> and mark it "inline" like the other mm_inline.h functions.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
