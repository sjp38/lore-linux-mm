Date: Fri, 2 Apr 2004 11:55:44 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity
    fix
In-Reply-To: <200404021221.15197@WOLK>
Message-ID: <Pine.LNX.4.44.0404021152030.4359-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marc-Christian Petersen <m.c.p@wolk-project.de>
Cc: linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>, vrajesh@umich.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Apr 2004, Marc-Christian Petersen wrote:
> 
> dunno if the below is causing your trouble, but is that intentional that 
> page_cache_release(page) is called twice?

It's not pretty, but it is intentional and correct:
the first to balance the page_cache_get higher up (well commented),
the second because add_to_page_cache does a page_cache_get but
remove_from_page_cache does not do the corresponding page_cache_release.

Christoph's problems will be somewhere in Andrea's compound page changes.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
