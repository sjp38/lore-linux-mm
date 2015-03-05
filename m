Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7DA246B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 15:46:43 -0500 (EST)
Received: by pdev10 with SMTP id v10so8748155pde.13
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 12:46:43 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id on8si10937008pdb.242.2015.03.05.12.46.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 12:46:42 -0800 (PST)
Date: Thu, 5 Mar 2015 21:46:32 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Resurrecting the VM_PINNED discussion
Message-ID: <20150305204632.GT21418@twins.programming.kicks-ass.net>
References: <20150303174105.GA3295@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150303174105.GA3295@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

On Tue, Mar 03, 2015 at 12:41:05PM -0500, Eric B Munson wrote:
> All,
> 
> After LSF/MM last year Peter revived a patch set that would create
> infrastructure for pinning pages as opposed to simply locking them.
> AFAICT, there was no objection to the set, it just needed some help
> from the IB folks.
> 
> Am I missing something about why it was never merged? 

Because I got lost in IB code and didn't manage to bribe anyone into
fixing that for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
