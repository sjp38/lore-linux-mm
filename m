Date: Sun, 18 Mar 2007 09:09:53 -0400
From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070318130953.GA2492@c2.user-mode-linux.org>
References: <20070221023735.6306.83373.sendpatchset@linux.site> <200703130001.13467.blaisorblade@yahoo.it> <20070313011904.GA2746@wotan.suse.de> <200703171317.01074.blaisorblade@yahoo.it> <20070318025010.GA1671@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070318025010.GA1671@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Blaisorblade <blaisorblade@yahoo.it>, Bill Irwin <bill.irwin@oracle.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Sun, Mar 18, 2007 at 03:50:10AM +0100, Nick Piggin wrote:
> Yes, that should be the case. So would this mean that nonlinear protections
> don't work on regular files? I guess that's OK if Oracle and UML both use
> tmpfs/shm?

It's OK for UML.

		Jeff

-- 
Work email - jdike at linux dot intel dot com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
