Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id ABD576B0037
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 12:51:28 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so904599eek.23
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 09:51:28 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x47si3524515eel.223.2014.04.08.09.51.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 09:51:27 -0700 (PDT)
Date: Tue, 8 Apr 2014 17:51:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
Message-ID: <20140408165123.GN7292@suse.de>
References: <20140407154935.GD7292@suse.de>
 <20140407161910.GJ1444@moon>
 <20140407182854.GH7292@suse.de>
 <5342FC0E.9080701@zytor.com>
 <20140407193646.GC23983@moon>
 <5342FFB0.6010501@zytor.com>
 <20140407212535.GJ7292@suse.de>
 <CAKbGBLhsWKVYnBqR0ZJ2kfaF_h=XAYkjq=v3RLoRBDkF_w=6ag@mail.gmail.com>
 <e9801da2-3aa4-4c23-9a64-90c890b9ebbc@email.android.com>
 <20140408160250.GE31554@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140408160250.GE31554@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Steven Noonan <steven@uplinklabs.net>, Cyrill Gorcunov <gorcunov@gmail.com>, David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Tue, Apr 08, 2014 at 12:02:50PM -0400, Konrad Rzeszutek Wilk wrote:
> .snip..
> > >>> David Vrabel has a patchset which I presumed would be pulled through
> > >the
> > >>> Xen tree this merge window:
> > >>>
> > >>> [PATCHv5 0/8] x86/xen: fixes for mapping high MMIO regions (and
> > >remove
> > >>> _PAGE_IOMAP)
> > >>>
> > >>> That frees up this bit.
> > >>>
> > >>
> > >> Thanks, I was not aware of that patch.  Based on it, I intend to
> > >force
> > >> automatic NUMA balancing to depend on !XEN and see what the reaction
> > >is. If
> > >> support for Xen is really required then it potentially be re-enabled
> > >if/when
> > >> that series is merged assuming they do not need the bit for something
> > >else.
> > >>
> > >
> > >Amazon EC2 does have large memory instance types with NUMA exposed to
> > >the guest (e.g. c3.8xlarge, i2.8xlarge, etc), so it'd be preferable
> > >(to me anyway) if we didn't require !XEN.
> 
> What about the patch that David Vrabel posted:
> 
> http://osdir.com/ml/general/2014-03/msg41979.html
> 
> Has anybody taken it for a spin?

Alternatively "[PATCH 4/5] mm: use paravirt friendly ops for NUMA
hinting ptes" which modifies the NUMA pte helpers instead of the main
set/clear ones.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
