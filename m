Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E92816B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 03:13:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v26-v6so5051129eds.9
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 00:13:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e40-v6si888540ede.100.2018.08.07.00.13.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 00:13:34 -0700 (PDT)
Date: Tue, 7 Aug 2018 09:13:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: memcg: update memcg OOM messages on cgroup2
Message-ID: <20180807071332.GR10003@dhcp22.suse.cz>
References: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
 <20180806161529.GA410235@devbig004.ftw2.facebook.com>
 <20180806200637.GJ10003@dhcp22.suse.cz>
 <20180806201907.GH410235@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180806201907.GH410235@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Mon 06-08-18 13:19:07, Tejun Heo wrote:
> Hello, Michal.
> 
> On Mon, Aug 06, 2018 at 10:06:37PM +0200, Michal Hocko wrote:
> > Is there really any reason to have each couner on a seprate line? This
> > is just too much of an output for a single oom report. I do get why you
> > are not really thrilled by the hierarchical numbers but can we keep
> > counters in a single line please?
> 
> Hmm... maybe, but can you please consider the followings?
> 
> * It's the same information as memory.stat but would be in a different
>   format and will likely be a bit of an eyeful.
>
> * It can easily become a really long line.  Each kernel log can be ~1k
>   in length and there can be other limits in the log pipeline
>   (e.g. netcons).

Are we getting close to those limits?

> * The information is already multi-line and cgroup oom kills don't
>   take down the system, so there's no need to worry about scroll back
>   that much.  Also, not printing recursive info means the output is
>   well-bound.

Well, on the other hand you can have a lot of memcgs under OOM and then
swamp the log a lot.
-- 
Michal Hocko
SUSE Labs
