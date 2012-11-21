Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 852436B002B
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 03:12:45 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so4804778eek.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 00:12:44 -0800 (PST)
Date: Wed, 21 Nov 2012 09:12:39 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH, v2] mm, numa: Turn 4K pte NUMA faults into effective
 hugepage ones
Message-ID: <20121121081239.GA23603@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
 <20121119211804.GM8218@suse.de>
 <20121119223604.GA13470@gmail.com>
 <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
 <20121120071704.GA14199@gmail.com>
 <20121120152933.GA17996@gmail.com>
 <20121120160918.GA18167@gmail.com>
 <50ABB06A.9000402@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50ABB06A.9000402@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Rik van Riel <riel@redhat.com> wrote:

> >+}
> >+
> >+/*
> >+ * Add a simple loop to also fetch ptes within the same pmd:
> >+ */
> 
> That's not a very useful comment. How about something like:
> 
>   /*
>    * Also fault over nearby ptes from within the same pmd and vma,
>    * in order to minimize the overhead from page fault exceptions
>    * and TLB flushes.
>    */

There's no TLB flushes here. But I'm fine with the other part so 
I've updated the comment to say:

/*
 * Also fault over nearby ptes from within the same pmd and vma,
 * in order to minimize the overhead from page fault exceptions:
 */

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
