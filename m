Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAFD6B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 09:33:23 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id v109so12631321wrc.5
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:33:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m188si1708519wme.135.2017.09.26.06.33.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 06:33:21 -0700 (PDT)
Date: Tue, 26 Sep 2017 15:33:20 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3] mm: introduce validity check on vm dirtiness settings
Message-ID: <20170926133320.GD13627@quack2.suse.cz>
References: <1505861015-11919-1-git-send-email-laoar.shao@gmail.com>
 <20170926102532.culqxb45xwzafomj@dhcp22.suse.cz>
 <CALOAHbAbFedJ-h+QUWeeoAnpeEfpYe2T1GutFb56kBeL=2jN0A@mail.gmail.com>
 <20170926112656.tbu7nr2lxdqt5rft@dhcp22.suse.cz>
 <CALOAHbB-H8vtGH4PE8Tr+jmvrQZc3bRXqnG9R1QBQfJKvaHP4g@mail.gmail.com>
 <20170926115423.wdnctuqtxbhpdidx@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170926115423.wdnctuqtxbhpdidx@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yafang Shao <laoar.shao@gmail.com>, Jan Kara <jack@suse.cz>, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, Theodore Ts'o <tytso@mit.edu>, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 26-09-17 13:54:23, Michal Hocko wrote:
> On Tue 26-09-17 19:45:45, Yafang Shao wrote:
> > >> > To be honest I am not entirely sure this is worth the code and the
> > >> > future maintenance burden.
> > >> I'm not sure if this code is a burden for the future maintenance, but
> > >> I think that if we don't introduce this code it is a burden to the
> > >> admins.
> > >
> > > anytime we might need to tweak background vs direct limit we would have
> > > to change these checks as well and that sounds like a maint. burden to
> > > me.
> > 
> > Would pls. show me some example ?
> 
> What kind of examples would you like to see. I meant that if the current
> logic of bacground vs. direct limit changes the code to check it which
> is at a different place IIRC would have to be kept in sync.
> 
> That being said, this is my personal opinion, I will not object if there
> is a general consensus on merging this. I just believe that this is not
> simply worth adding a single line of code. You can then a lot of harm by
> setting different values which would pass the added check.

So I personally think that the checks Yafang added are worth the extra
code. The situation with ratio/bytes interface and hard/background limit is
complex enough that it makes sense to have basic sanity checks to me. That
being said I don't have too strong opinion on this so just documentation
update would be also fine by me.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
