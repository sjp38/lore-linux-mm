Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id BA81D900002
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 04:25:06 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so667482pab.16
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 01:25:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id e4si826969pdl.408.2014.07.11.01.25.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jul 2014 01:25:05 -0700 (PDT)
Date: Fri, 11 Jul 2014 10:25:00 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: + shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
 added to -mm tree
Message-ID: <20140711082500.GB20603@laptop.programming.kicks-ass.net>
References: <53BD1053.5020401@suse.cz>
 <53BD39FC.7040205@oracle.com>
 <53BD67DC.9040700@oracle.com>
 <alpine.LSU.2.11.1407092358090.18131@eggly.anvils>
 <53BE8B1B.3000808@oracle.com>
 <53BECBA4.3010508@oracle.com>
 <alpine.LSU.2.11.1407101033280.18934@eggly.anvils>
 <53BED7F6.4090502@oracle.com>
 <alpine.LSU.2.11.1407101131310.19154@eggly.anvils>
 <53BEE345.4090203@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53BEE345.4090203@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, davej@redhat.com, koct9i@gmail.com, lczerner@redhat.com, stable@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 10, 2014 at 03:02:29PM -0400, Sasha Levin wrote:
> What if we move lockdep's acquisition point to after it actually got the
> lock?

NAK, you want to do deadlock detection _before_ you're stuck in a
deadlock.

> We'd miss deadlocks, but we don't care about them right now. Anyways, doesn't
> lockdep have anything built in to allow us to separate between locks which
> we attempt to acquire and locks that are actually acquired?
> 
> (cc PeterZ)
> 
> We can treat locks that are in the process of being acquired the same as
> acquired locks to avoid races, but when we print something out it would
> be nice to have annotation of the read state of the lock.

I'm missing the problem here I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
