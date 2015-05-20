Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 934156B0133
	for <linux-mm@kvack.org>; Wed, 20 May 2015 12:44:23 -0400 (EDT)
Received: by wibt6 with SMTP id t6so66748140wib.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 09:44:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t1si4742616wif.84.2015.05.20.09.44.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 May 2015 09:44:22 -0700 (PDT)
Date: Wed, 20 May 2015 17:44:19 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm, memcg: Optionally disable memcg by default using
 Kconfig
Message-ID: <20150520164419.GT2462@suse.de>
References: <1432126245-10908-1-git-send-email-mgorman@suse.de>
 <1432126245-10908-3-git-send-email-mgorman@suse.de>
 <20150520162421.GB2874@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150520162421.GB2874@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Linux-CGroups <cgroups@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 20, 2015 at 12:24:21PM -0400, Johannes Weiner wrote:
> > 
> > Low thread counts get a small boost but it's within noise as memcg overhead
> > does not dominate. It's not obvious at all at higher thread counts as other
> > factors cause more problems. The overall breakdown of CPU usage looks like
> > 
> >                4.0.0       4.0.0
> >         chargefirst-v2r1disable-v2r1
> > User           41.81       41.45
> > System        407.64      405.50
> > Elapsed       128.17      127.06
> 
> This is a worst case microbenchmark doing nothing but anonymous page
> faults (with THP disabled), and yet the performance difference is in
> the noise.  I don't see why we should burden the user with making a
> decision that doesn't matter in theory, let alone in practice.
> 
> We have CONFIG_MEMCG and cgroup_disable=memory, that should be plenty
> for users that obsess about fluctuation in the noise.  There is no
> reason to complicate the world further for everybody else.

FWIW, I agree and only included this patch because I said I would
yesterday. After patch 1, there is almost no motivation to disable memcg
at all let alone by default.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
