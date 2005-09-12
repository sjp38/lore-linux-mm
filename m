Date: Mon, 12 Sep 2005 19:21:56 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] shrink_list skip anon pages if not may_swap
In-Reply-To: <1126546191.5182.29.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.63.0509121921450.28108@cuia.boston.redhat.com>
References: <1126546191.5182.29.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Martin Hicks <mort@sgi.com>, lhms-devel <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Sep 2005, Lee Schermerhorn wrote:

> This patch modifies shrink_list() to skip anon pages that are not
> already in the swap cache when !may_swap, rather than just not adding
> them to the cache.

Nice catch!

-- 
All Rights Reversed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
