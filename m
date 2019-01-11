Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B50B88E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:37:01 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id s71so9664095pfi.22
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:37:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m64si10114993pfb.224.2019.01.10.23.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 23:37:00 -0800 (PST)
Date: Fri, 11 Jan 2019 08:36:55 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <20190110004424.GH27534@dastard>
Message-ID: <nycvar.YFH.7.76.1901110836110.6626@cbobk.fhfr.pm>
References: <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com> <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com> <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com> <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm> <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, 10 Jan 2019, Dave Chinner wrote:

> Sounds nice from a theoretical POV, but reality has taught us very 
> different lessons.
> 
> FWIW, a quick check of XFS's history so you understand how long this 
> behaviour has been around. It was introduced in the linux port in 2001 
> as direct IO support was being added:
> 
> commit e837eac23662afae603aaaef7c94bc839c1b8f67
> Author: Steve Lord <lord@sgi.com>
> Date:   Mon Mar 5 16:47:52 2001 +0000
> 
>     Add bounds checking for direct I/O, do the cache invalidation for
>     data coherency on direct I/O.

Out of curiosity, which repository is this from please? Even google 
doesn't seem to know about this SHA.

Thanks,

-- 
Jiri Kosina
SUSE Labs
