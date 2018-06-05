Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65D726B0007
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 06:28:52 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j8-v6so1133577wrh.18
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 03:28:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h63-v6si12141017edd.152.2018.06.05.03.28.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Jun 2018 03:28:50 -0700 (PDT)
Date: Tue, 5 Jun 2018 12:28:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: don't skip memory guarantee calculations
Message-ID: <20180605102849.GZ19202@dhcp22.suse.cz>
References: <20180522132528.23769-1-guro@fb.com>
 <20180522132528.23769-2-guro@fb.com>
 <20180604122953.GN19202@dhcp22.suse.cz>
 <20180604162259.GA3404@castle>
 <20180605090349.GW19202@dhcp22.suse.cz>
 <20180605101544.GB5464@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180605101544.GB5464@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue 05-06-18 11:15:45, Roman Gushchin wrote:
> On Tue, Jun 05, 2018 at 11:03:49AM +0200, Michal Hocko wrote:
> > On Mon 04-06-18 17:23:06, Roman Gushchin wrote:
> > [...]
> > > I'm happy to discuss any concrete issues/concerns, but I really see
> > > no reasons to drop it from the mm tree now and start the discussion
> > > from scratch.
> > 
> > I do not think this is ready for the current merge window. Sorry! I
> > would really prefer to see the whole thing in one series to have a
> > better picture.
> 
> Please, provide any specific reason for that. I appreciate your opinion,
> but *I think* it's not an argument, seriously.

Seeing two follow up fixes close to the merge window just speaks for
itself. Besides that there is not need to rush this now.
 
> We've discussed the patchset back to March and I made several iterations
> based on the received feedback. Later we had a separate discussion with Greg,
> who proposed an alternative solution, which, unfortunately, had some serious
> shortcomings. And, as I remember, some time ago we've discussed memory.min
> with you.
> And now you want to start from scratch without providing any reason.
> I find it counter-productive, sorry.

I am sorry I couldn't give it more time, but this release cycle was even
crazier than usual.
-- 
Michal Hocko
SUSE Labs
