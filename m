Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B460E6B026D
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:57:19 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id x66so8299652pfe.21
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:57:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c7si17976971plo.298.2017.11.15.06.57.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 06:57:18 -0800 (PST)
Date: Wed, 15 Nov 2017 15:57:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Message-ID: <20171115145716.w34jaez5ljb3fssn@dhcp22.suse.cz>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
 <20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz>
 <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
 <20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz>
 <20171115144314.xwdi2sbcn6m6lqdo@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115144314.xwdi2sbcn6m6lqdo@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yasu.isimatu@gmail.com, koki.sanagi@us.fujitsu.com

On Wed 15-11-17 14:43:14, Mel Gorman wrote:
> On Wed, Nov 15, 2017 at 03:28:16PM +0100, Michal Hocko wrote:
> > On Wed 15-11-17 14:13:29, Mel Gorman wrote:
> > [...]
> > > I doubt anyone well. Even the original reporter appeared to pick that
> > > particular value just to trigger the OOM.
> > 
> > Then why do we care at all? The trace buffer size can be configured from
> > the userspace if it is not sufficiently large IIRC.
> > 
> 
> I guess there is the potential that the trace buffer needs to be large
> enough early on in boot but I'm not sure why it would need to be that large
> to be honest. Bottom line, it's fairly trivial to just serialise meminit
> in the event that it's resized from command line. I'm also ok with just
> leaving this is as a "don't set the buffer that large"

I would be reluctant to touch the code just because of insane kernel
command line option.

That being said, I will not object or block the patch it just seems
unnecessary for most reasonable setups I can think of. If there is a
legitimate usage of such a large trace buffer then I wouldn't oppose.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
