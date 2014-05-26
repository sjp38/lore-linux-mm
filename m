Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7FF736B0036
	for <linux-mm@kvack.org>; Mon, 26 May 2014 16:19:17 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hl10so320857igb.3
        for <linux-mm@kvack.org>; Mon, 26 May 2014 13:19:17 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id s1si1812655ign.15.2014.05.26.13.19.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 May 2014 13:19:17 -0700 (PDT)
Received: by mail-ig0-f179.google.com with SMTP id hn18so329903igb.0
        for <linux-mm@kvack.org>; Mon, 26 May 2014 13:19:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140526145605.016140154@infradead.org>
References: <20140526145605.016140154@infradead.org>
Date: Tue, 27 May 2014 00:19:16 +0400
Message-ID: <CALYGNiMG1NVBUS4TJrYJMr92yWGZHSdGUdCGtBJDHoUMMhE+Wg@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/5] VM_PINNED
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Mon, May 26, 2014 at 6:56 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> Hi all,
>
> I mentioned at LSF/MM that I wanted to revive this, and at the time there were
> no disagreements.
>
> I finally got around to refreshing the patch(es) so here goes.
>
> These patches introduce VM_PINNED infrastructure, vma tracking of persistent
> 'pinned' page ranges. Pinned is anything that has a fixed phys address (as
> required for say IO DMA engines) and thus cannot use the weaker VM_LOCKED. One
> popular way to pin pages is through get_user_pages() but that not nessecarily
> the only way.

Lol, this looks like resurrection of VM_RESERVED which I've removed
not so long time ago.

Maybe single-bit state isn't flexible enought?
This supposed to supports pinning only by one user and only in its own mm?

This might be done as extension of existing memory-policy engine.
It allows to keep vm_area_struct slim in normal cases and change
behaviour when needed.
memory-policy might hold reference-counter of "pinners", track
ownership and so on.

>
> Roland, as said, I need some IB assistance, see patches 4 and 5, where I got
> lost in the qib and ipath code.
>
> Patches 1-3 compile tested.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
