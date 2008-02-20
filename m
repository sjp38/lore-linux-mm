Date: Wed, 20 Feb 2008 02:09:41 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch] my mmu notifiers
Message-ID: <20080220010941.GR7128@v2.random>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080219231157.GC18912@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2008 at 12:11:57AM +0100, Nick Piggin wrote:
> Sorry, I realise I still didn't get this through my head yet (and also
> have not seen your patch recently). So I don't know exactly what you
> are doing...

The last version was posted here:

http://marc.info/?l=kvm-devel&m=120321732521533&w=2

> But why does _anybody_ (why does Christoph's patches) need to invalidate
> when they are going to be more permissive? This should be done lazily by
> the driver, I would have thought.

This can be done lazily by the driver yes. The place where I've an
invalidate_pages in mprotect however can also become less permissive.
It's simpler to invalidate always and it's not guaranteed the
secondary mmu page fault is capable of refreshing the spte across a
writeprotect fault. In the future this can be changed to
mprotect_pages though, so no page fault will happen in the secondary
mmu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
