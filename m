Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 049948E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:54:12 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id v187so9671275ywv.15
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:54:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a202sor4359604ywe.41.2019.01.28.06.54.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Jan 2019 06:54:11 -0800 (PST)
Date: Mon, 28 Jan 2019 06:54:07 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190128145407.GP50184@devbig004.ftw2.facebook.com>
References: <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190128142816.GM50184@devbig004.ftw2.facebook.com>
 <20190128145210.GM18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128145210.GM18811@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hello,

On Mon, Jan 28, 2019 at 03:52:10PM +0100, Michal Hocko wrote:
> > All .events files generate aggregated stateful notifications.  For
> > anyone to do anything, they'd have to remember the previous state to
> > identify what actually happened.  Being hierarchical, it'd of course
> > need to walk down when an event triggers.
> 
> And how do you do that in a raceless fashion?

Hmm... I'm having trouble imagining why this would be a problem.  How
would it race?

Thanks.

-- 
tejun
