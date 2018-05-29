Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A9F336B0007
	for <linux-mm@kvack.org>; Tue, 29 May 2018 08:37:09 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e1-v6so9239199pld.23
        for <linux-mm@kvack.org>; Tue, 29 May 2018 05:37:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k189-v6si25757581pgc.414.2018.05.29.05.37.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 May 2018 05:37:08 -0700 (PDT)
Date: Tue, 29 May 2018 14:37:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] doc: document scope NOFS, NOIO APIs
Message-ID: <20180529123704.GT27180@dhcp22.suse.cz>
References: <20180524114341.1101-1-mhocko@kernel.org>
 <20180529082644.26192-1-mhocko@kernel.org>
 <20180529055158.0170231e@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529055158.0170231e@lwn.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Dave Chinner <david@fromorbit.com>, Randy Dunlap <rdunlap@infradead.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue 29-05-18 05:51:58, Jonathan Corbet wrote:
> On Tue, 29 May 2018 10:26:44 +0200
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > Although the api is documented in the source code Ted has pointed out
> > that there is no mention in the core-api Documentation and there are
> > people looking there to find answers how to use a specific API.
> 
> So, I still think that this:
> 
> > +The traditional way to avoid this deadlock problem is to clear __GFP_FS
> > +respectively __GFP_IO (note the latter implies clearing the first as well) in
> 
> doesn't read the way you intend it to.  But we've sent you in more
> than enough circles on this already, so I went ahead and applied it;
> wording can always be tweaked later.

Thanks a lot Jonathan! I am open to any suggestions of course and can
follow up with some refinements. Just for the background. The above
paragraph is meant to say that:
- clearing __GFP_FS is a way to avoid reclaim recursion into filesystems
  deadlocks
- clearing __GFP_IO is a way to avoid reclaim recursion into the IO
  layer deadlocks
- GFP_NOIO implies __GFP_NOFS

> You added the kerneldoc comments, but didn't bring them into your new
> document.  I'm going to tack this on afterward, hopefully nobody will
> object.

I have to confess I've never studied how the rst and kerneldoc should be
interlinked so thanks for the fix up!
-- 
Michal Hocko
SUSE Labs
