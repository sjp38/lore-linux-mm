Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id AAF0F6B0035
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 11:05:35 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id lx4so2583257iec.9
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 08:05:34 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id m10si1554615icu.169.2014.04.09.08.05.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 08:05:28 -0700 (PDT)
Date: Wed, 9 Apr 2014 11:04:48 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
Message-ID: <20140409150448.GE5860@phenom.dumpdata.com>
References: <20140407161910.GJ1444@moon>
 <20140407182854.GH7292@suse.de>
 <5342FC0E.9080701@zytor.com>
 <20140407193646.GC23983@moon>
 <5342FFB0.6010501@zytor.com>
 <20140407212535.GJ7292@suse.de>
 <CAKbGBLhsWKVYnBqR0ZJ2kfaF_h=XAYkjq=v3RLoRBDkF_w=6ag@mail.gmail.com>
 <e9801da2-3aa4-4c23-9a64-90c890b9ebbc@email.android.com>
 <CAKbGBLjO7pneg_5nXcRXK-9iToZvPkJVZ=AQBfaZkZjU9iN2BA@mail.gmail.com>
 <5344631D.1050203@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5344631D.1050203@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Steven Noonan <steven@uplinklabs.net>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Tue, Apr 08, 2014 at 01:59:09PM -0700, H. Peter Anvin wrote:
> On 04/08/2014 01:51 PM, Steven Noonan wrote:
> > On Tue, Apr 8, 2014 at 8:16 AM, H. Peter Anvin <hpa@zytor.com> wrote:
> >> <snark>
> >>
> >> Of course, it would also be preferable if Amazon (or anything else) didn't need Xen PV :(
> > 
> > Well Amazon doesn't expose NUMA on PV, only on HVM guests.
> > 
> 
> Yes, but Amazon is one of the main things keeping Xen PV alive as far as
> I can tell, which means the support gets built in, and so on.

Taking the snarkiness aside, the issue here is that even on guests
without NUMA exposed the problem shows up. That is the 'mknuma' are
still being called even if the guest topology is not NUMA!

Which brings a question - why isn't the mknuma and its friends gatted by
an jump_label machinery or such?

Mel, any particular reasons why it couldn't be done this way?
> 
> 	-hpa
> 
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
