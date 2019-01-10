Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4469C8E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 02:54:34 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id c14so5751556pls.21
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 23:54:34 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h127si5946522pfe.204.2019.01.09.23.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 23:54:32 -0800 (PST)
Date: Thu, 10 Jan 2019 08:54:23 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <20190110011533.GI27534@dastard>
Message-ID: <nycvar.YFH.7.76.1901100852080.6626@cbobk.fhfr.pm>
References: <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com> <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com> <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com> <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm> <20190109043906.GF27534@dastard> <nycvar.YFH.7.76.1901091050560.16954@cbobk.fhfr.pm>
 <20190110011533.GI27534@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, 10 Jan 2019, Dave Chinner wrote:

> > Yeah, preadv2(RWF_NOWAIT) is in the same teritory as mincore(), it has 
> > "just" been overlooked. I can't speak for Daniel, but I believe he might 
> > be ok with rephrasing the above as "Restricting mincore() and RWF_NOWAIT 
> > is sufficient ...".
> 
> Good luck with restricting RWF_NOWAIT. I eagerly await all the
> fstests that exercise both the existing and new behaviours to
> demonstrate they work correctly.

Well, we can still resurrect my original aproach of doing this opt-in 
based on a sysctl setting, and letting the admin choose his poison.

If 'secure' mode is selected, RWF_NOWAIT will then probably just always 
fail wit EAGAIN.

-- 
Jiri Kosina
SUSE Labs
