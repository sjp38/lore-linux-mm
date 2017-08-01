Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA9C6B0539
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:29:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a186so2260274wmh.9
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:29:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w140si1161278wmw.19.2017.08.01.05.29.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 05:29:08 -0700 (PDT)
Date: Tue, 1 Aug 2017 14:29:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] mm, oom: do not grant oom victims full memory
 reserves access
Message-ID: <20170801122905.GL15774@dhcp22.suse.cz>
References: <20170727090357.3205-1-mhocko@kernel.org>
 <20170801121643.GI15774@dhcp22.suse.cz>
 <20170801122344.GA8457@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170801122344.GA8457@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 01-08-17 13:23:44, Roman Gushchin wrote:
> On Tue, Aug 01, 2017 at 02:16:44PM +0200, Michal Hocko wrote:
> > On Thu 27-07-17 11:03:55, Michal Hocko wrote:
> > > Hi,
> > > this is a part of a larger series I posted back in Oct last year [1]. I
> > > have dropped patch 3 because it was incorrect and patch 4 is not
> > > applicable without it.
> > > 
> > > The primary reason to apply patch 1 is to remove a risk of the complete
> > > memory depletion by oom victims. While this is a theoretical risk right
> > > now there is a demand for memcg aware oom killer which might kill all
> > > processes inside a memcg which can be a lot of tasks. That would make
> > > the risk quite real.
> > > 
> > > This issue is addressed by limiting access to memory reserves. We no
> > > longer use TIF_MEMDIE to grant the access and use tsk_is_oom_victim
> > > instead. See Patch 1 for more details. Patch 2 is a trivial follow up
> > > cleanup.
> > 
> > Any comments, concerns? Can we merge it?
> 
> I've rebased the cgroup-aware OOM killer and ran some tests.
> Everything works well.

Thanks for your testing. Can I assume your Tested-by?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
