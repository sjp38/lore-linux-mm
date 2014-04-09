Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8C46B0031
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 11:10:00 -0400 (EDT)
Received: by mail-ie0-f180.google.com with SMTP id as1so2458459iec.25
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 08:09:59 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id nv5si10778558igb.41.2014.04.09.08.09.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Apr 2014 08:09:56 -0700 (PDT)
Date: Wed, 9 Apr 2014 17:09:37 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
Message-ID: <20140409150935.GC10526@twins.programming.kicks-ass.net>
References: <20140407182854.GH7292@suse.de>
 <5342FC0E.9080701@zytor.com>
 <20140407193646.GC23983@moon>
 <5342FFB0.6010501@zytor.com>
 <20140407212535.GJ7292@suse.de>
 <CAKbGBLhsWKVYnBqR0ZJ2kfaF_h=XAYkjq=v3RLoRBDkF_w=6ag@mail.gmail.com>
 <e9801da2-3aa4-4c23-9a64-90c890b9ebbc@email.android.com>
 <CAKbGBLjO7pneg_5nXcRXK-9iToZvPkJVZ=AQBfaZkZjU9iN2BA@mail.gmail.com>
 <5344631D.1050203@zytor.com>
 <20140409150448.GE5860@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409150448.GE5860@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Steven Noonan <steven@uplinklabs.net>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Wed, Apr 09, 2014 at 11:04:48AM -0400, Konrad Rzeszutek Wilk wrote:
> On Tue, Apr 08, 2014 at 01:59:09PM -0700, H. Peter Anvin wrote:
> > On 04/08/2014 01:51 PM, Steven Noonan wrote:
> > > On Tue, Apr 8, 2014 at 8:16 AM, H. Peter Anvin <hpa@zytor.com> wrote:
> > >> <snark>
> > >>
> > >> Of course, it would also be preferable if Amazon (or anything else) didn't need Xen PV :(
> > > 
> > > Well Amazon doesn't expose NUMA on PV, only on HVM guests.
> > > 
> > 
> > Yes, but Amazon is one of the main things keeping Xen PV alive as far as
> > I can tell, which means the support gets built in, and so on.
> 
> Taking the snarkiness aside, the issue here is that even on guests
> without NUMA exposed the problem shows up. That is the 'mknuma' are
> still being called even if the guest topology is not NUMA!
> 
> Which brings a question - why isn't the mknuma and its friends gatted by
> an jump_label machinery or such?
> 
> Mel, any particular reasons why it couldn't be done this way?

Hmm,. I thought we disabled all that when there was only the 1 node. All
this should be driven from task_tick_numa() which only gets called when
numabalancing_enabled, and that _should_ be false when nr_nodes == 1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
