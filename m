Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CDFC6B0389
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 05:21:25 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id le4so11881801wjb.1
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 02:21:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 140si11758901wmt.40.2017.02.20.02.21.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Feb 2017 02:21:23 -0800 (PST)
Date: Mon, 20 Feb 2017 11:21:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3 staging-next] android: Lowmemmorykiller task tree
Message-ID: <20170220102121.GF2431@dhcp22.suse.cz>
References: <df828d70-3962-2e43-0512-1777a9842bb2@sonymobile.com>
 <20170210102732.GB10054@dhcp22.suse.cz>
 <5579dead-092d-2ce2-a9d4-f2b50721f0dc@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5579dead-092d-2ce2-a9d4-f2b50721f0dc@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Mon 13-02-17 16:42:42, peter enderborg wrote:
> On 02/10/2017 11:27 AM, Michal Hocko wrote:
> > [I have only now see this cover - it answers some of the questions I've
> >  had to specific patches. It would be really great if you could use git
> >  send-email to post patch series - it just does the right thing(tm)]
> >
> > On Thu 09-02-17 14:21:40, peter enderborg wrote:
> >> Lowmemorykiller efficiency problem and a solution.
> >>
> >> Lowmemorykiller in android has a severe efficiency problem. The basic
> >> problem is that the registered shrinker gets called very often without
> >>  anything actually happening.
> > Which is an inherent problem because lkml doesn't belong to shrinkers
> > infrastructure.
> 
> Not really what this patch address.  I see it as a problem with shrinker
> that there no slow-path-free (scan/count) where it should belong.
> This patch address a specific problem where lot of cpu are wasted
> in low memory conditions.

Let me repeat. The specific problem you are trying to solve is
_inherent_ to how the lmk is designed. Full stop.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
