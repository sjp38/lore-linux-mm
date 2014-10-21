Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 53C096B0098
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 06:43:56 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so1092836pdi.5
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 03:43:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id lf12si10587998pab.192.2014.10.21.03.43.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 03:43:55 -0700 (PDT)
Date: Tue, 21 Oct 2014 12:43:47 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 5/6] mm: Provide speculative fault infrastructure
Message-ID: <20141021104347.GC12706@worktop.programming.kicks-ass.net>
References: <CAJd=RBAF3BS9GvPW+fNB9DNzyHrBZk4qNfU6QKUhNNKTMYkmNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBAF3BS9GvPW+fNB9DNzyHrBZk4qNfU6QKUhNNKTMYkmNQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, linux-mm@kvack.org, "hillf.zj" <hillf.zj@alibaba-inc.com>

On Tue, Oct 21, 2014 at 05:07:56PM +0800, Hillf Danton wrote:
> > +	pte = pte_offset_map(pmd, address);
> > +	fe.entry = ACCESS_ONCE(pte); /* XXX gup_get_pte() */
> 
> I wonder if one char, "*", is missing.
>
> > +	pte_unmap(pte);

Gah yes, last minute edit that. I noticed I missed the pte_unmap() while
doing the changelogs and 'fixed' up the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
