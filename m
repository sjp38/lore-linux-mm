Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 972B66B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 08:29:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 187so640247wmn.2
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 05:29:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m20si11133792wrf.300.2017.09.13.05.29.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 05:29:16 -0700 (PDT)
Date: Wed, 13 Sep 2017 14:29:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
References: <20170911131742.16482-1-guro@fb.com>
 <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 11-09-17 13:44:39, David Rientjes wrote:
> On Mon, 11 Sep 2017, Roman Gushchin wrote:
> 
> > This patchset makes the OOM killer cgroup-aware.
> > 
> > v8:
> >   - Do not kill tasks with OOM_SCORE_ADJ -1000
> >   - Make the whole thing opt-in with cgroup mount option control
> >   - Drop oom_priority for further discussions
> 
> Nack, we specifically require oom_priority for this to function correctly, 
> otherwise we cannot prefer to kill from low priority leaf memcgs as 
> required.

While I understand that your usecase might require priorities I do not
think this part missing is a reason to nack the cgroup based selection
and kill-all parts. This can be done on top. The only important part
right now is the current selection semantic - only leaf memcgs vs. size
of the hierarchy). I strongly believe that comparing only leaf memcgs
is more straightforward and it doesn't lead to unexpected results as
mentioned before (kill a small memcg which is a part of the larger
sub-hierarchy).

I didn't get to read the new version of this series yet and hope to get
to it soon.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
