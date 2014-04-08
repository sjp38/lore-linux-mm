Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5C86B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 12:47:50 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so906252eek.34
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 09:47:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si3505313eei.265.2014.04.08.09.47.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Apr 2014 09:47:47 -0700 (PDT)
Date: Tue, 8 Apr 2014 17:47:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] x86: Define _PAGE_NUMA with unused physical address
 bits PMD and PTE levels
Message-ID: <20140408164744.GM7292@suse.de>
References: <20140407161910.GJ1444@moon>
 <20140407182854.GH7292@suse.de>
 <5342FC0E.9080701@zytor.com>
 <20140407193646.GC23983@moon>
 <5342FFB0.6010501@zytor.com>
 <20140407212535.GJ7292@suse.de>
 <CAKbGBLhsWKVYnBqR0ZJ2kfaF_h=XAYkjq=v3RLoRBDkF_w=6ag@mail.gmail.com>
 <e9801da2-3aa4-4c23-9a64-90c890b9ebbc@email.android.com>
 <20140408160250.GE31554@phenom.dumpdata.com>
 <534420F1.3030301@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <534420F1.3030301@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Steven Noonan <steven@uplinklabs.net>, Cyrill Gorcunov <gorcunov@gmail.com>, David Vrabel <david.vrabel@citrix.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Tue, Apr 08, 2014 at 09:16:49AM -0700, H. Peter Anvin wrote:
> On 04/08/2014 09:02 AM, Konrad Rzeszutek Wilk wrote:
> >>>
> >>> Amazon EC2 does have large memory instance types with NUMA exposed to
> >>> the guest (e.g. c3.8xlarge, i2.8xlarge, etc), so it'd be preferable
> >>> (to me anyway) if we didn't require !XEN.
> > 
> > What about the patch that David Vrabel posted:
> > 
> > http://osdir.com/ml/general/2014-03/msg41979.html
> > 
> > Has anybody taken it for a spin?
> > 
> 
> Oh lovely, more pvops in low level paths.  I'm so thrilled.
> 
> Incidentally, I wasn't even Cc:'d on that patch and was only added to
> the thread by Linus, but never saw the early bits of the thread
> including the actual patch.
> 

I posted an alternative to that patch that confines the damage to the
NUMA pte helpers.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
