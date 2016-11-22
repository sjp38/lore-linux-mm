Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD576B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:06:37 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j65so63285156iof.1
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 08:06:37 -0800 (PST)
Received: from mail1.merlins.org (magic.merlins.org. [209.81.13.136])
        by mx.google.com with ESMTPS id u63si20079461ioi.37.2016.11.22.08.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 Nov 2016 08:06:35 -0800 (PST)
Date: Tue, 22 Nov 2016 08:06:29 -0800
From: Marc MERLIN <marc@merlins.org>
Message-ID: <20161122160629.uzt2u6m75ash4ved@merlins.org>
References: <20161121154336.GD19750@merlins.org>
 <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161121215639.GF13371@merlins.org>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>

On Mon, Nov 21, 2016 at 01:56:39PM -0800, Marc MERLIN wrote:
> On Mon, Nov 21, 2016 at 10:50:20PM +0100, Vlastimil Babka wrote:
> > > 4.9rc5 however seems to be doing better, and is still running after 18
> > > hours. However, I got a few page allocation failures as per below, but the
> > > system seems to recover.
> > > Vlastimil, do you want me to continue the copy on 4.9 (may take 3-5 days) 
> > > or is that good enough, and i should go back to 4.8.8 with that patch applied?
> > > https://marc.info/?l=linux-mm&m=147423605024993
> > 
> > Hi, I think it's enough for 4.9 for now and I would appreciate trying
> > 4.8 with that patch, yeah.
> 
> So the good news is that it's been running for almost 5H and so far so good.

And the better news is that the copy is still going strong, 4.4TB and
going. So 4.8.8 is fixed with that one single patch as far as I'm
concerned.

So thanks for that, looks good to me to merge.

Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/                         | PGP 1024R/763BE901

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
