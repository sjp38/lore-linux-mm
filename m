Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFD476B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 05:39:33 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v66so7434035wrc.4
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 02:39:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k32si5926974wre.130.2017.03.16.02.39.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 02:39:32 -0700 (PDT)
Date: Thu, 16 Mar 2017 10:39:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
Message-ID: <20170316093931.GH30501@dhcp22.suse.cz>
References: <20170227090236.GA2789@bbox>
 <20170227094448.GF14029@dhcp22.suse.cz>
 <20170228051723.GD2702@bbox>
 <20170228081223.GA26792@dhcp22.suse.cz>
 <20170302071721.GA32632@bbox>
 <feebcc24-2863-1bdf-e586-1ac9648b35ba@wiesinger.com>
 <20170316082714.GC30501@dhcp22.suse.cz>
 <20170316084733.GP802@shells.gnugeneration.com>
 <20170316090844.GG30501@dhcp22.suse.cz>
 <20170316092318.GQ802@shells.gnugeneration.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170316092318.GQ802@shells.gnugeneration.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml@pengaru.com
Cc: Gerhard Wiesinger <lists@wiesinger.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu 16-03-17 02:23:18, lkml@pengaru.com wrote:
> On Thu, Mar 16, 2017 at 10:08:44AM +0100, Michal Hocko wrote:
> > On Thu 16-03-17 01:47:33, lkml@pengaru.com wrote:
> > [...]
> > > While on the topic of understanding allocation stalls, Philip Freeman recently
> > > mailed linux-kernel with a similar report, and in his case there are plenty of
> > > page cache pages.  It was also a GFP_HIGHUSER_MOVABLE 0-order allocation.
> > 
> > care to point me to the report?
> 
> http://lkml.iu.edu/hypermail/linux/kernel/1703.1/06360.html

Thanks. It is gone from my lkml mailbox. Could you CC me (and linux-mm) please?
 
> >  
> > > I'm no MM expert, but it appears a bit broken for such a low-order allocation
> > > to stall on the order of 10 seconds when there's plenty of reclaimable pages,
> > > in addition to mostly unused and abundant swap space on SSD.
> > 
> > yes this might indeed signal a problem.
> 
> Well maybe I missed something obvious that a better informed eye will catch.

Nothing really obvious. There is indeed a lot of anonymous memory to
swap out. Almost no pages on file LRU lists (active_file:759
inactive_file:749) but 158783 total pagecache pages so we have to have a
lot of pages in the swap cache. I would probably have to see more data
to make a full picture.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
