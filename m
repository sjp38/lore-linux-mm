Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 964796B009B
	for <linux-mm@kvack.org>; Tue, 27 May 2014 10:34:44 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id i8so14211779qcq.15
        for <linux-mm@kvack.org>; Tue, 27 May 2014 07:34:44 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id w75si17163598qge.77.2014.05.27.07.34.43
        for <linux-mm@kvack.org>;
        Tue, 27 May 2014 07:34:44 -0700 (PDT)
Date: Tue, 27 May 2014 09:34:22 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [RFC][PATCH 0/5] VM_PINNED
In-Reply-To: <20140527102909.GO30445@twins.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.10.1405270929550.13999@gentwo.org>
References: <20140526145605.016140154@infradead.org> <CALYGNiMG1NVBUS4TJrYJMr92yWGZHSdGUdCGtBJDHoUMMhE+Wg@mail.gmail.com> <20140526203232.GC5444@laptop.programming.kicks-ass.net> <CALYGNiO8FNKjtETQMRSqgiArjfQ9nRAALUg9GGdNYbpKru=Sjw@mail.gmail.com>
 <20140527102909.GO30445@twins.programming.kicks-ass.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Tue, 27 May 2014, Peter Zijlstra wrote:

> The things I care about for VM_PINNED are long term pins, like the IB
> stuff, which sets up its RDMA buffers at the start of a program and
> basically leaves them in place for the entire duration of said program.

Ok that also means the pages are not to be allocated from ZONE_MOVABLE?

I expected the use of a page flag. With a vma flag we may have a situation
that mapping a page into a vma changes it to pinned and terminating a
process may unpin a page. That means the zone that the page should be
allocated from changes.

Pinned pages in ZONE_MOVABLE are not a good idea. But since "kernelcore"
is rarely used maybe that is not an issue?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
