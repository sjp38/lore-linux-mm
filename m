Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 481526B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 16:09:45 -0500 (EST)
Received: by qgfi50 with SMTP id i50so8008885qgf.10
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 13:09:45 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id w6si5302076qkw.118.2015.03.05.13.09.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 13:09:44 -0800 (PST)
Date: Thu, 5 Mar 2015 15:09:42 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Resurrecting the VM_PINNED discussion
In-Reply-To: <20150305204632.GT21418@twins.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.11.1503051508130.790@gentwo.org>
References: <20150303174105.GA3295@akamai.com> <20150305204632.GT21418@twins.programming.kicks-ass.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Thu, 5 Mar 2015, Peter Zijlstra wrote:

> > Am I missing something about why it was never merged?
>
> Because I got lost in IB code and didn't manage to bribe anyone into
> fixing that for me.

Well the complexity increased since then with the on demand pinning,
mmu notifiers etc etc ...

I thought the clear distinction between pinning and mlocking would do the
trick?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
