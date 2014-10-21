Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 859136B0095
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 06:42:31 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fb1so1130852pad.25
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 03:42:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id yn7si10645590pab.122.2014.10.21.03.42.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 03:42:30 -0700 (PDT)
Date: Tue, 21 Oct 2014 12:42:25 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 5/6] mm: Provide speculative fault infrastructure
Message-ID: <20141021104225.GB12706@worktop.programming.kicks-ass.net>
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

> > Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

> btw, and more important, still correct for me to
> address you Redhater, Sir?

Clue in the above line ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
