Date: Thu, 3 May 2007 01:05:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: incoming
Message-Id: <20070503010535.b18a49d6.akpm@linux-foundation.org>
In-Reply-To: <20070503075543.GA12018@flint.arm.linux.org.uk>
References: <20070502150252.7ddf67ac.akpm@linux-foundation.org>
	<20070503075543.GA12018@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk+lkml@arm.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@engr.sgi.com>, "David S. Miller" <davem@davemloft.net>, Andi Kleen <ak@suse.de>, "Luck, Tony" <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 May 2007 08:55:43 +0100 Russell King <rmk+lkml@arm.linux.org.uk> wrote:

> On Wed, May 02, 2007 at 03:02:52PM -0700, Andrew Morton wrote:
> > So this is what I have lined up for the first mm->2.6.22 batch.  I won't be
> > sending it off for another 12-24 hours yet.  To give people time for final
> > comment and to give me time to see if it actually works.
> 
> I assume you're going to update this list with my comments I sent
> yesterday?
> 

Serial drivers?  Well you saw me drop a bunch of them.  I now have:

serial-driver-pmc-msp71xx.patch
rm9000-serial-driver.patch
serial-define-fixed_port-flag-for-serial_core.patch
mpsc-serial-driver-tx-locking.patch
serial-serial_core-use-pr_debug.patch

I'll also be holding off on MADV_FREE - Nick has some performance things to
share and I'm assuming they're not as good as he'd like.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
