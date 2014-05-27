Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 424F86B0088
	for <linux-mm@kvack.org>; Tue, 27 May 2014 09:09:34 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id l6so13925298qcy.3
        for <linux-mm@kvack.org>; Tue, 27 May 2014 06:09:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id v8si16825422qgd.76.2014.05.27.06.09.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 May 2014 06:09:32 -0700 (PDT)
Date: Tue, 27 May 2014 15:09:26 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 0/5] VM_PINNED
Message-ID: <20140527130926.GE5444@laptop.programming.kicks-ass.net>
References: <20140526145605.016140154@infradead.org>
 <CALYGNiMG1NVBUS4TJrYJMr92yWGZHSdGUdCGtBJDHoUMMhE+Wg@mail.gmail.com>
 <20140526203232.GC5444@laptop.programming.kicks-ass.net>
 <CALYGNiO8FNKjtETQMRSqgiArjfQ9nRAALUg9GGdNYbpKru=Sjw@mail.gmail.com>
 <20140527102909.GO30445@twins.programming.kicks-ass.net>
 <20140527105438.GW13658@twins.programming.kicks-ass.net>
 <CALYGNiNCp5ShyKLAQi_cht_-sPt79Zxzj=Q=VSzqCvdnsCE5ag@mail.gmail.com>
 <53847C17.2080609@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53847C17.2080609@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Tue, May 27, 2014 at 01:50:47PM +0200, Vlastimil Babka wrote:
> > What if VM_PINNED will require VM_LOCKED?
> > I.e. user must mlock it before pining and cannot munlock vma while it's pinned.
> 
> Mlocking makes sense, as pages won't be uselessly scanned on
> non-evictable LRU, no? (Or maybe I just don't see that something else
> prevents then from being there already).

We can add VM_PINNED logic to page_check_reference() and
try_to_unmap_one() to avoid the scanning if that's a problem. But that's
additional bits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
