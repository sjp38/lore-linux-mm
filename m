Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 206258E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 16:06:32 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id e89so8260066pfb.17
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 13:06:32 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id v16si2662992pgg.290.2019.01.17.13.06.29
        for <linux-mm@kvack.org>;
        Thu, 17 Jan 2019 13:06:30 -0800 (PST)
Date: Fri, 18 Jan 2019 08:06:10 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190117210610.GW4205@dastard>
References: <20190108044336.GB27534@dastard>
 <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard>
 <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard>
 <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard>
 <nycvar.YFH.7.76.1901110836110.6626@cbobk.fhfr.pm>
 <20190117022244.GV4205@dastard>
 <nycvar.YFH.7.76.1901170917490.6626@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1901170917490.6626@cbobk.fhfr.pm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 17, 2019 at 09:18:41AM +0100, Jiri Kosina wrote:
> On Thu, 17 Jan 2019, Dave Chinner wrote:
> 
> > > > commit e837eac23662afae603aaaef7c94bc839c1b8f67
> > > > Author: Steve Lord <lord@sgi.com>
> > > > Date:   Mon Mar 5 16:47:52 2001 +0000
> > > > 
> > > >     Add bounds checking for direct I/O, do the cache invalidation for
> > > >     data coherency on direct I/O.
> > > 
> > > Out of curiosity, which repository is this from please? Even google 
> > > doesn't seem to know about this SHA.
> > 
> > because oss.sgi.com is no longer with us, it's fallen out of all the
> > search engines.  It was from the "archive/xfs-import.git" tree on
> > oss.sgi.com:
> > 
> > https://web.archive.org/web/20120326044237/http://oss.sgi.com:80/cgi-bin/gitweb.cgi
> > 
> > but archive.org doesn't have a copy of the git tree. It contained
> > the XFS history right back to the first Irix commit in 1993. Some of
> > us still have copies of it sitting around....
> 
> For cases like this, would it be worth pushing it to git.kernel.org as an 
> frozen historical reference archive?

I'm not sure we should be putting code from Irix on kernel.org. I
uploaded a copy to github a few months ago so XFS devs could easily
reference relevant commits in email. The reasons we decided not to
upload it to kernel.org should be clear from the readme...

https://github.com/dchinner/xfs-history

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
