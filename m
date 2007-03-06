Date: Mon, 5 Mar 2007 16:54:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [rfc][patch 1/2] mm: rework isolate_lru_page
Message-Id: <20070305165406.6fbf7489.akpm@linux-foundation.org>
In-Reply-To: <20070305161655.GC8128@wotan.suse.de>
References: <20070305161655.GC8128@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

I'm doing a patch massacre on the -mm tree in an attempt to stabilise
things.  Given that the move-mlocked-and-anon-pages-off-the-lru work
appears to be upgraded, and given that another mm developer is actually
looking at them, I dropped 'em.

The remains are at http://userweb.kernel.org/~akpm/dropped-patches/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
