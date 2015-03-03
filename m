Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 12D9C6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 15:22:44 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id w8so29884675qac.8
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 12:22:43 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id j33si770140qkh.58.2015.03.03.12.22.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 12:22:42 -0800 (PST)
Date: Tue, 3 Mar 2015 14:22:41 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Resurrecting the VM_PINNED discussion
In-Reply-To: <54F617A2.8040405@suse.cz>
Message-ID: <alpine.DEB.2.11.1503031422260.16199@gentwo.org>
References: <20150303174105.GA3295@akamai.com> <54F5FEE0.2090104@suse.cz> <20150303184520.GA4996@akamai.com> <54F617A2.8040405@suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Tue, 3 Mar 2015, Vlastimil Babka wrote:

> It also passes TTU_IGNORE_MLOCK to try_to_unmap(). So what am I missing? Where
> is this restriction?

Its in the defrag code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
