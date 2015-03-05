Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3472B6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 16:13:22 -0500 (EST)
Received: by wibhm9 with SMTP id hm9so18400872wib.2
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 13:13:21 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id n9si37441672wia.101.2015.03.05.13.13.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 13:13:20 -0800 (PST)
Date: Thu, 5 Mar 2015 22:13:06 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Resurrecting the VM_PINNED discussion
Message-ID: <20150305211306.GV21418@twins.programming.kicks-ass.net>
References: <20150303174105.GA3295@akamai.com>
 <20150305204632.GT21418@twins.programming.kicks-ass.net>
 <alpine.DEB.2.11.1503051508130.790@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1503051508130.790@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Thu, Mar 05, 2015 at 03:09:42PM -0600, Christoph Lameter wrote:
> On Thu, 5 Mar 2015, Peter Zijlstra wrote:
> 
> > > Am I missing something about why it was never merged?
> >
> > Because I got lost in IB code and didn't manage to bribe anyone into
> > fixing that for me.
> 
> Well the complexity increased since then with the on demand pinning,
> mmu notifiers etc etc ...

Clearly I've not been paying attention, what? Is this that drug induced
stuff benh was babbling about a while back?

> I thought the clear distinction between pinning and mlocking would do the
> trick?

Nah, it still leaves the accounting up shit creek.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
