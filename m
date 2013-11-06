Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 74C206B00CC
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 06:02:16 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id wy17so5721321pbc.28
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 03:02:16 -0800 (PST)
Received: from psmtp.com ([74.125.245.201])
        by mx.google.com with SMTP id z1si5972876pbn.301.2013.11.06.03.02.13
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 03:02:14 -0800 (PST)
Date: Wed, 6 Nov 2013 12:02:00 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: create a separate slab for page->ptl allocation
Message-ID: <20131106110200.GI10651@twins.programming.kicks-ass.net>
References: <1382442839-7458-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20131105150145.734a5dd5b5d455800ebfa0d3@linux-foundation.org>
 <20131105224217.GC20167@shutemov.name>
 <20131105155619.021f32eba1ca8f15a73ed4c9@linux-foundation.org>
 <20131105231310.GE20167@shutemov.name>
 <20131106103403.GB21074@mudshark.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131106103403.GB21074@mudshark.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Wed, Nov 06, 2013 at 10:34:03AM +0000, Will Deacon wrote:
> FWIW: if the architecture selects ARCH_USE_CMPXCHG_LOCKREF, then a spinlock_t
> is 32-bit (assuming that unsigned int is also 32-bit).

Egads, talk about fragile. That thing relies on someone actually keeping
lib/Kconfig up-to-date.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
