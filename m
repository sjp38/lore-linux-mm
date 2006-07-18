Date: Mon, 17 Jul 2006 20:37:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm: inactive-clean list
In-Reply-To: <1153167857.31891.78.camel@lappy>
Message-ID: <Pine.LNX.4.64.0607172035140.28956@schroedinger.engr.sgi.com>
References: <1153167857.31891.78.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jul 2006, Peter Zijlstra wrote:

> This patch implements the inactive_clean list spoken of during the VM summit.
> The LRU tail pages will be unmapped and ready to free, but not freeed.
> This gives reclaim an extra chance.

I thought we wanted to just track the number of unmapped clean pages and 
insure that they do not go under a certain limit? That would not require
any locking changes but just a new zoned counter and a check in the dirty
handling path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
