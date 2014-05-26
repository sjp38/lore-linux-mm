Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id F022F6B0036
	for <linux-mm@kvack.org>; Mon, 26 May 2014 16:32:40 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id t60so8622912wes.13
        for <linux-mm@kvack.org>; Mon, 26 May 2014 13:32:40 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id cf5si2100864wib.38.2014.05.26.13.32.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 May 2014 13:32:39 -0700 (PDT)
Date: Mon, 26 May 2014 22:32:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 0/5] VM_PINNED
Message-ID: <20140526203232.GC5444@laptop.programming.kicks-ass.net>
References: <20140526145605.016140154@infradead.org>
 <CALYGNiMG1NVBUS4TJrYJMr92yWGZHSdGUdCGtBJDHoUMMhE+Wg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiMG1NVBUS4TJrYJMr92yWGZHSdGUdCGtBJDHoUMMhE+Wg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Tue, May 27, 2014 at 12:19:16AM +0400, Konstantin Khlebnikov wrote:
> On Mon, May 26, 2014 at 6:56 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > Hi all,
> >
> > I mentioned at LSF/MM that I wanted to revive this, and at the time there were
> > no disagreements.
> >
> > I finally got around to refreshing the patch(es) so here goes.
> >
> > These patches introduce VM_PINNED infrastructure, vma tracking of persistent
> > 'pinned' page ranges. Pinned is anything that has a fixed phys address (as
> > required for say IO DMA engines) and thus cannot use the weaker VM_LOCKED. One
> > popular way to pin pages is through get_user_pages() but that not nessecarily
> > the only way.
> 
> Lol, this looks like resurrection of VM_RESERVED which I've removed
> not so long time ago.

Not sure what VM_RESERVED did, but there might be a similarity.

> Maybe single-bit state isn't flexible enought?

Not sure what you mean, the one bit is perfectly fine for what I want it
to do.

> This supposed to supports pinning only by one user and only in its own mm?

Pretty much, that's adequate for all users I'm aware of and mirrors the
mlock semantics.

> This might be done as extension of existing memory-policy engine.
> It allows to keep vm_area_struct slim in normal cases and change
> behaviour when needed.
> memory-policy might hold reference-counter of "pinners", track
> ownership and so on.

That all sounds like raping the mempolicy code and massive over
engineering.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
