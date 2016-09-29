Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id E7ACB6B02A4
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 03:44:05 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id cg13so127178789pac.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 00:44:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id uf7si13069503pab.103.2016.09.29.00.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 00:44:04 -0700 (PDT)
Date: Thu, 29 Sep 2016 09:43:56 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160929074356.GA2784@worktop>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net>
 <20160928005318.2f474a70@roar.ozlabs.ibm.com>
 <20160927165221.GP5016@twins.programming.kicks-ass.net>
 <20160928030621.579ece3a@roar.ozlabs.ibm.com>
 <20160928070546.GT2794@worktop>
 <20160929113132.5a85b887@roar.ozlabs.ibm.com>
 <20160929062132.GG3318@worktop.controleur.wifipass.org>
 <20160929164231.166d2910@roar.ozlabs.ibm.com>
 <20160929071451.GI3318@worktop.controleur.wifipass.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160929071451.GI3318@worktop.controleur.wifipass.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Alan Stern <stern@rowland.harvard.edu>

On Thu, Sep 29, 2016 at 09:14:51AM +0200, Peter Zijlstra wrote:
> On Thu, Sep 29, 2016 at 04:42:31PM +1000, Nicholas Piggin wrote:
> > Take Alpha instead. It's using 32-bit ops.
> 
> Hmm, my Alpha docs are on the other machine, but I suppose the problem
> is 64bit immediates (which would be a common problem I suppose, those
> don't really work well on x86 either).

OK, so from the architecture that have 64bit support, I think Alpha is
the only one that uses 32bit ops and cares.

alpha is weak and uses 32bit ops (fail)
arm64 is weak but uses 64bit ops
ia64 has full barriers and 64bit ops
mips is weak but uses 64bit ops
parisc is horrid but uses 64bit ops
powerpc is weak but uses 64bit ops
s390 has full barriers and uses 64bit ops
sparc has full barriers and uses 64bit ops (if I read the asm right)
tile is weak but uses 64bit ops
x86 has full barriers and uses byte ops

So we could just fix Alpha..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
