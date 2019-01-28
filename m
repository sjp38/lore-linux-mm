Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 99A1D8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:19:03 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b7so6733840eda.10
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 07:19:03 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o13si785902ejs.213.2019.01.28.07.19.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 07:19:02 -0800 (PST)
Date: Mon, 28 Jan 2019 16:18:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190128151859.GO18811@dhcp22.suse.cz>
References: <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190128142816.GM50184@devbig004.ftw2.facebook.com>
 <20190128145210.GM18811@dhcp22.suse.cz>
 <20190128145407.GP50184@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128145407.GP50184@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Mon 28-01-19 06:54:07, Tejun Heo wrote:
> Hello,
> 
> On Mon, Jan 28, 2019 at 03:52:10PM +0100, Michal Hocko wrote:
> > > All .events files generate aggregated stateful notifications.  For
> > > anyone to do anything, they'd have to remember the previous state to
> > > identify what actually happened.  Being hierarchical, it'd of course
> > > need to walk down when an event triggers.
> > 
> > And how do you do that in a raceless fashion?
> 
> Hmm... I'm having trouble imagining why this would be a problem.  How
> would it race?

How do you make an atomic snapshot of the hierarchy state? Or you do
not need it because event counters are monotonic and you are willing to
sacrifice some lost or misinterpreted events? For example, you receive
an oom event while the two children increase the oom event counter. How
do you tell which one was the source of the event and which one is still
pending? Or is the ordering unimportant in general?

I can imagine you can live with this model, but having a hierarchical
reporting without a source of the event just sounds too clumsy from my
POV. But I guess this is getting tangent to the original patch.
-- 
Michal Hocko
SUSE Labs
