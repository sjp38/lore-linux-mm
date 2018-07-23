Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 680E56B0006
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 04:30:47 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t17-v6so106593edr.21
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:30:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m21-v6si5787340edq.379.2018.07.23.01.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 01:30:46 -0700 (PDT)
Date: Mon, 23 Jul 2018 10:30:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/5] mm/page_alloc: Optimize free_area_init_core
Message-ID: <20180723083043.GF17905@dhcp22.suse.cz>
References: <20180719132740.32743-1-osalvador@techadventures.net>
 <20180719132740.32743-4-osalvador@techadventures.net>
 <20180719134417.GC7193@dhcp22.suse.cz>
 <20180719140327.GB10988@techadventures.net>
 <20180719151555.GH7193@dhcp22.suse.cz>
 <20180719205235.GA14010@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719205235.GA14010@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: akpm@linux-foundation.org, pasha.tatashin@oracle.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

On Thu 19-07-18 22:52:35, Oscar Salvador wrote:
> On Thu, Jul 19, 2018 at 05:15:55PM +0200, Michal Hocko wrote:
> > Your changelog doesn't really explain the motivation. Does the change
> > help performance? Is this a pure cleanup?
> 
> Hi Michal,
> 
> Sorry to not have explained this better from the very beginning.
> 
> It should help a bit in performance terms as we would be skipping those
> condition checks and assignations for zones that do not have any pages.
> It is not a huge win, but I think that skipping code we do not really need to run
> is worh to have.

It is always preferable to have numbers when you are claiming
performance benefits.

> 
> > The function is certainly not an example of beauty. It is more an
> > example of changes done on top of older ones without much thinking. But
> > I do not see your change would make it so much better. I would consider
> > it a much nicer cleanup if it was split into logical units each doing
> > one specific thing.
> 
> About the cleanup, I thought that moving that block of code to a separate function
> would make the code easier to follow.
> If you think that this is still not enough, I can try to split it and see the outcome.

Well, on the other hand, is the change really worth it? Moving code
around is not free either. Any git blame tracking to understand why the
code is done this way will be harder.

But just to make it clear, I do not want to discourage you from touching
this area. I just believe that if you really want to do that then the
result shouldn't just tweak one specific case and tweak it. It would be
much more appreciated if the new code had much better structure and less
hacks.
-- 
Michal Hocko
SUSE Labs
