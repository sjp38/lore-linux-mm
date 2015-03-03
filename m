Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 32A416B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 14:51:18 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id j5so11442769qga.12
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 11:51:17 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id e37si1431315qgd.75.2015.03.03.11.51.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 11:51:17 -0800 (PST)
Date: Tue, 3 Mar 2015 13:51:12 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Resurrecting the VM_PINNED discussion
In-Reply-To: <20150303184520.GA4996@akamai.com>
Message-ID: <alpine.DEB.2.11.1503031349360.15876@gentwo.org>
References: <20150303174105.GA3295@akamai.com> <54F5FEE0.2090104@suse.cz> <20150303184520.GA4996@akamai.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Tue, 3 Mar 2015, Eric B Munson wrote:

> > So you are saying that mlocking (VM_LOCKED) prevents migration and thus
> > compaction to do its job? If that's true, I think it's a bug as it is AFAIK
> > supposed to work just fine.
>
> Agreed.  But as has been discussed in the threads around the VM_PINNED
> work, there are people that are relying on the fact that VM_LOCKED
> promises no minor faults.  Which is why the behavoir has remained.

AFAICT mlocking preventing migration is something that could be taken out.
Google removes the restriction.

mlocked does not promise no minor faults only that the page will stay
resident. The pinning results in no faults.

> VM_PINNED itself doesn't help us, but it would allow us to make
> VM_LOCKED use only the weaker 'no major fault' semantics while still
> providing a way for anyone that needs the stronger 'no minor fault'
> promise to get the semantics they need.

The semantics for mlock allow migration and therefore defrag as well as
thp processing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
