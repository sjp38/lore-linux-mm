Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 618D16B00A5
	for <linux-mm@kvack.org>; Tue, 27 May 2014 11:14:14 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id q107so14017198qgd.38
        for <linux-mm@kvack.org>; Tue, 27 May 2014 08:14:14 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id l5si17783481qad.26.2014.05.27.08.14.13
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 08:14:13 -0700 (PDT)
Date: Tue, 27 May 2014 10:14:10 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC][PATCH 0/5] VM_PINNED
In-Reply-To: <20140527144655.GC19143@laptop.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.10.1405271011100.14466@gentwo.org>
References: <20140526145605.016140154@infradead.org> <CALYGNiMG1NVBUS4TJrYJMr92yWGZHSdGUdCGtBJDHoUMMhE+Wg@mail.gmail.com> <20140526203232.GC5444@laptop.programming.kicks-ass.net> <CALYGNiO8FNKjtETQMRSqgiArjfQ9nRAALUg9GGdNYbpKru=Sjw@mail.gmail.com>
 <20140527102909.GO30445@twins.programming.kicks-ass.net> <alpine.DEB.2.10.1405270929550.13999@gentwo.org> <20140527144655.GC19143@laptop.programming.kicks-ass.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Tue, 27 May 2014, Peter Zijlstra wrote:

> Well, like with IB, they start out as normal userspace pages, and will
> be from ZONE_MOVABLE.

Well we could change that now I think. If the VMA has VM_PINNED set
pages then do not allocate from ZONE_MOVABLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
