Date: Mon, 4 Aug 2003 07:08:14 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.0-test2-mm4
Message-ID: <20030804140814.GJ32488@holomorphy.com>
References: <20030804013036.16d9fa3a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030804013036.16d9fa3a.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Mon, Aug 04, 2003 at 01:30:36AM -0700, Andrew Morton wrote:
> +4g4g-pmd-fix.patch

If you're going to back out pgd preconstruction, at least back it out
all the way so list poison isn't tripped over randomly on PAE. This is
actually worse than before, since you're basically doing list_del()
on whatever value of page->lru was handed to mm/slab.c from page_alloc.c
in pgd_dtor() multiple times per-page and pounding the lock for no
reason whatsoever on PAE. It's also degrading performance on non-PAE
due to the fact no preconstruction is done there, though harmless due
to the fact the only trace of pgd preconstruction left is the AGP fix.

Someone please tell me they realize this is a backout because absolutely
zero data structure initialization is done in ->ctor() and the entire
thing is memcpy()'d and memset()'d over in the front end to the slab.

I have no idea what, if anything has been absorbed from my prior posts
on this subject. AFAICT I'm getting dead air (or worse) back from
everyone else and no one's even bothering to read the code. i.e. either
no one understands a word I'm saying or no one's listening.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
