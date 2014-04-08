Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4DBB66B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 12:03:29 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id ur14so1242071igb.4
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 09:03:29 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ql8si3934960igc.9.2014.04.08.09.03.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 09:03:28 -0700 (PDT)
Date: Tue, 8 Apr 2014 12:02:50 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
Message-ID: <20140408160250.GE31554@phenom.dumpdata.com>
References: <5342C517.2020305@citrix.com>
 <20140407154935.GD7292@suse.de>
 <20140407161910.GJ1444@moon>
 <20140407182854.GH7292@suse.de>
 <5342FC0E.9080701@zytor.com>
 <20140407193646.GC23983@moon>
 <5342FFB0.6010501@zytor.com>
 <20140407212535.GJ7292@suse.de>
 <CAKbGBLhsWKVYnBqR0ZJ2kfaF_h=XAYkjq=v3RLoRBDkF_w=6ag@mail.gmail.com>
 <e9801da2-3aa4-4c23-9a64-90c890b9ebbc@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e9801da2-3aa4-4c23-9a64-90c890b9ebbc@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Steven Noonan <steven@uplinklabs.net>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

.snip..
> >>> David Vrabel has a patchset which I presumed would be pulled through
> >the
> >>> Xen tree this merge window:
> >>>
> >>> [PATCHv5 0/8] x86/xen: fixes for mapping high MMIO regions (and
> >remove
> >>> _PAGE_IOMAP)
> >>>
> >>> That frees up this bit.
> >>>
> >>
> >> Thanks, I was not aware of that patch.  Based on it, I intend to
> >force
> >> automatic NUMA balancing to depend on !XEN and see what the reaction
> >is. If
> >> support for Xen is really required then it potentially be re-enabled
> >if/when
> >> that series is merged assuming they do not need the bit for something
> >else.
> >>
> >
> >Amazon EC2 does have large memory instance types with NUMA exposed to
> >the guest (e.g. c3.8xlarge, i2.8xlarge, etc), so it'd be preferable
> >(to me anyway) if we didn't require !XEN.

What about the patch that David Vrabel posted:

http://osdir.com/ml/general/2014-03/msg41979.html

Has anybody taken it for a spin?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
