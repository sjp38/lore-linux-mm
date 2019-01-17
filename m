Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C99438E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 03:18:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id z10so3372778edz.15
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 00:18:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l24si505628edr.135.2019.01.17.00.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 00:18:43 -0800 (PST)
Date: Thu, 17 Jan 2019 09:18:41 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <20190117022244.GV4205@dastard>
Message-ID: <nycvar.YFH.7.76.1901170917490.6626@cbobk.fhfr.pm>
References: <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com> <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com> <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm> <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com> <20190110004424.GH27534@dastard> <nycvar.YFH.7.76.1901110836110.6626@cbobk.fhfr.pm>
 <20190117022244.GV4205@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, 17 Jan 2019, Dave Chinner wrote:

> > > commit e837eac23662afae603aaaef7c94bc839c1b8f67
> > > Author: Steve Lord <lord@sgi.com>
> > > Date:   Mon Mar 5 16:47:52 2001 +0000
> > > 
> > >     Add bounds checking for direct I/O, do the cache invalidation for
> > >     data coherency on direct I/O.
> > 
> > Out of curiosity, which repository is this from please? Even google 
> > doesn't seem to know about this SHA.
> 
> because oss.sgi.com is no longer with us, it's fallen out of all the
> search engines.  It was from the "archive/xfs-import.git" tree on
> oss.sgi.com:
> 
> https://web.archive.org/web/20120326044237/http://oss.sgi.com:80/cgi-bin/gitweb.cgi
> 
> but archive.org doesn't have a copy of the git tree. It contained
> the XFS history right back to the first Irix commit in 1993. Some of
> us still have copies of it sitting around....

For cases like this, would it be worth pushing it to git.kernel.org as an 
frozen historical reference archive?

Thanks,

-- 
Jiri Kosina
SUSE Labs
