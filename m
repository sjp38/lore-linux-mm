Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 939146B0047
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 06:08:55 -0500 (EST)
Date: Sun, 17 Jan 2010 06:08:47 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] register MADV_HUGEPAGE
Message-ID: <20100117110847.GA32212@infradead.org>
References: <20100116184642.GA5687@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100116184642.GA5687@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Sat, Jan 16, 2010 at 07:46:42PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> In order to allow early shipping transparent hugepage feature enabled
> only inside MADV_HUGEPAGE and not globally to diminish the risk of
> unexpected performance regressions on non-hypervisor related usages
> I'd need this little define registered. This is also to avoid things
> like this:

NACK, usespace ABIs only go in when features are added.  There's a more
than large enough chance that it will change for one reason or another.

And while transparent hugepages are a good feature to add, it's still in
a far to early stage to go on with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
