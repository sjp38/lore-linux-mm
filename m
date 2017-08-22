Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29004280725
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 15:37:17 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t193so104447372pgc.0
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 12:37:17 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k5si9187000pgp.450.2017.08.22.12.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 12:37:16 -0700 (PDT)
Date: Tue, 22 Aug 2017 12:37:14 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Message-ID: <20170822193714.GZ28715@tassilo.jf.intel.com>
References: <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net>
 <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378A24A@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy=4y0fq9nL2WR1x8vwzJrDOdv++r036LXpR=6Jx8jpzg@mail.gmail.com>
 <20170822190828.GO32112@worktop.programming.kicks-ass.net>
 <CA+55aFzPt401xpRzd6Qu-WuDNGneR_m7z25O=0YspNi+cLRb8w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzPt401xpRzd6Qu-WuDNGneR_m7z25O=0YspNi+cLRb8w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "Liang, Kan" <kan.liang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

> > Still, generating such a migration storm would be fairly tricky I think.
> 
> Well, Mel seems to have been unable to generate a load that reproduces
> the long page waitqueues. And I don't think we've had any other
> reports of this either.

It could be that it requires a fairly large system. On large systems
under load a lot of things take much longer, so what's a tiny window on Mel's
system may suddenly be very large, and with much more threads 
they have a higher chance of bad interactions anyways.

We only see it on 4S+ today. But systems are always getting larger,
so what's a large system today, will be a normal medium scale system
tomorrow.

BTW we also collected PT traces for the long hang cases, but it was
hard to find a consistent pattern in them.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
