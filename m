Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1688C6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 06:16:26 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x6-v6so1150007wrl.6
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 03:16:26 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q10-v6si4898724edk.369.2018.06.05.03.16.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 03:16:24 -0700 (PDT)
Date: Tue, 5 Jun 2018 11:15:45 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 2/2] mm: don't skip memory guarantee calculations
Message-ID: <20180605101544.GB5464@castle>
References: <20180522132528.23769-1-guro@fb.com>
 <20180522132528.23769-2-guro@fb.com>
 <20180604122953.GN19202@dhcp22.suse.cz>
 <20180604162259.GA3404@castle>
 <20180605090349.GW19202@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180605090349.GW19202@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jun 05, 2018 at 11:03:49AM +0200, Michal Hocko wrote:
> On Mon 04-06-18 17:23:06, Roman Gushchin wrote:
> [...]
> > I'm happy to discuss any concrete issues/concerns, but I really see
> > no reasons to drop it from the mm tree now and start the discussion
> > from scratch.
> 
> I do not think this is ready for the current merge window. Sorry! I
> would really prefer to see the whole thing in one series to have a
> better picture.

Please, provide any specific reason for that. I appreciate your opinion,
but *I think* it's not an argument, seriously.

We've discussed the patchset back to March and I made several iterations
based on the received feedback. Later we had a separate discussion with Greg,
who proposed an alternative solution, which, unfortunately, had some serious
shortcomings. And, as I remember, some time ago we've discussed memory.min
with you.
And now you want to start from scratch without providing any reason.
I find it counter-productive, sorry.

Thanks!
