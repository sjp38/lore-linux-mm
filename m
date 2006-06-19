Date: Mon, 19 Jun 2006 08:35:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch] rfc: fix splice mapping race?
In-Reply-To: <20060618094157.GD14452@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0606190826540.1184@schroedinger.engr.sgi.com>
References: <20060618094157.GD14452@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@engr.sgi.com>, Jens Axboe <axboe@suse.de>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 18 Jun 2006, Nick Piggin wrote:

> In page migration, detect the missing mapping early and bail out if
> that is the case: the page is not going to get un-truncated, so
> retrying is just a waste of time.

Note that swap_page() has been removed in Andrew's tree.

We already check for the mapping being NULL before we get to 
swap_page by the way. See migrate_pages().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
