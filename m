Date: Mon, 14 Mar 2005 13:50:21 -0800
From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/4] sparsemem intro patches
Message-Id: <20050314135021.639d1533.davem@davemloft.net>
In-Reply-To: <1110834883.19340.47.camel@localhost>
References: <1110834883.19340.47.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Mar 2005 13:14:43 -0800
Dave Hansen <haveblue@us.ibm.com> wrote:

> Three of these are i386-only, but one of them reorganizes the macros
> used to manage the space in page->flags, and will affect all platforms.
> There are analogous patches to the i386 ones for ppc64, ia64, and
> x86_64, but those will be submitted by the normal arch maintainers.

Sparc64 uses some of the upper page->flags bits to store D-cache
flushing state.

Specifically, PG_arch_1 is used to set whether the page is scheduled
for delayed D-cache flushing, and bits 24 and up say which CPU the
CPU stores occurred on (and thus which CPU will get the cross-CPU
message to flush it's D-cache should the deferred flush actually
occur).

I imagine that since we don't support the domain stuff (yet) on sparc64,
your patches won't break things, but it is something to be aware of.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
