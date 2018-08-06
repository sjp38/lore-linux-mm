Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 523906B0003
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 16:19:12 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id a14-v6so14422358ybl.10
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 13:19:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q75-v6sor2909072ybg.161.2018.08.06.13.19.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 13:19:10 -0700 (PDT)
Date: Mon, 6 Aug 2018 13:19:07 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] mm: memcg: update memcg OOM messages on cgroup2
Message-ID: <20180806201907.GH410235@devbig004.ftw2.facebook.com>
References: <20180803175743.GW1206094@devbig004.ftw2.facebook.com>
 <20180806161529.GA410235@devbig004.ftw2.facebook.com>
 <20180806200637.GJ10003@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180806200637.GJ10003@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hello, Michal.

On Mon, Aug 06, 2018 at 10:06:37PM +0200, Michal Hocko wrote:
> Is there really any reason to have each couner on a seprate line? This
> is just too much of an output for a single oom report. I do get why you
> are not really thrilled by the hierarchical numbers but can we keep
> counters in a single line please?

Hmm... maybe, but can you please consider the followings?

* It's the same information as memory.stat but would be in a different
  format and will likely be a bit of an eyeful.

* It can easily become a really long line.  Each kernel log can be ~1k
  in length and there can be other limits in the log pipeline
  (e.g. netcons).

* The information is already multi-line and cgroup oom kills don't
  take down the system, so there's no need to worry about scroll back
  that much.  Also, not printing recursive info means the output is
  well-bound.

Thanks.

-- 
tejun
