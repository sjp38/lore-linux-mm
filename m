Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8B16B006E
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 20:24:19 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so32100066pab.12
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 17:24:18 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id hc9si7726471pbc.228.2015.01.28.17.24.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 17:24:18 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so32158997pac.2
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 17:24:18 -0800 (PST)
Date: Thu, 29 Jan 2015 10:24:07 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: OOM at low page cache?
Message-ID: <20150129012356.GA9672@blaptop>
References: <54C2C89C.8080002@gmail.com>
 <54C77086.7090505@suse.cz>
 <20150128062609.GA4706@blaptop>
 <54C8EF16.5080701@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54C8EF16.5080701@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Moser <john.r.moser@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>

Hello,

On Wed, Jan 28, 2015 at 09:15:50AM -0500, John Moser wrote:
> On 01/28/2015 01:26 AM, Minchan Kim wrote:
> > Hello,
> >
> > On Tue, Jan 27, 2015 at 12:03:34PM +0100, Vlastimil Babka wrote:
> >> CC linux-mm in case somebody has a good answer but missed this in lkml traffic
> >>
> >> On 01/23/2015 11:18 PM, John Moser wrote:
> >>> Why is there no tunable to OOM at low page cache?
> > AFAIR, there were several trial although there wasn't acceptable
> > at that time. One thing I can remember is min_filelist_kbytes.
> > FYI, http://lwn.net/Articles/412313/
> >
> 
> That looks more straight-forward than http://lwn.net/Articles/422291/
> 
> 
> > I'm far away from reclaim code for a long time but when I read again,
> > I found something strange.
> >
> > With having swap in get_scan_count, we keep a mount of file LRU + free
> > as above than high wmark to prevent file LRU thrashing but we don't
> > with no swap. Why?
> >
> 
> That's ... strange.  That means having a token 1MB swap file changes the
> system's practical memory reclaim behavior dramatically?

Basically, yes but 1M is too small. If all of swap consumed, the behavior
will be same so I think we need more explicit logic to prevent cache
thrashing. Could you test below patch?

Thanks.
