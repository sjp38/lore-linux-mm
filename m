Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA786B00E0
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 09:32:29 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id y10so10155731pdj.38
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 06:32:28 -0800 (PST)
Received: from psmtp.com ([74.125.245.201])
        by mx.google.com with SMTP id ai2si17570506pad.1.2013.11.06.06.32.26
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 06:32:27 -0800 (PST)
Date: Wed, 6 Nov 2013 15:32:14 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: lockref: Use bloated_spinlocks to avoid explicit config
 dependencies
Message-ID: <20131106143214.GP10651@twins.programming.kicks-ass.net>
References: <1382442839-7458-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20131105150145.734a5dd5b5d455800ebfa0d3@linux-foundation.org>
 <20131105224217.GC20167@shutemov.name>
 <20131105155619.021f32eba1ca8f15a73ed4c9@linux-foundation.org>
 <20131105231310.GE20167@shutemov.name>
 <20131106093131.GU28601@twins.programming.kicks-ass.net>
 <20131106111845.GG26785@twins.programming.kicks-ass.net>
 <20131106133112.GB22132@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131106133112.GB22132@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Nov 06, 2013 at 03:31:12PM +0200, Kirill A. Shutemov wrote:
> Should we get rid of CONFIG_CMPXCHG_LOCKREF completely and have here:
> 
> #if defined(CONFIG_ARCH_USE_CMPXCHG_LOCKREF) && \
> 	defined(CONFIG_SMP) && !BLOATED_SPINLOCKS
> 

Yeah, that might make more sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
