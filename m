Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3CEA36B026B
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 20:50:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r21-v6so224332edp.23
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 17:50:53 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id e8-v6si581243edq.87.2018.08.01.17.50.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 17:50:52 -0700 (PDT)
Date: Wed, 1 Aug 2018 17:50:26 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 1/3] mm: introduce mem_cgroup_put() helper
Message-ID: <20180802005023.GA1881@castle.DHCP.thefacebook.com>
References: <20180802003201.817-1-guro@fb.com>
 <20180802003201.817-2-guro@fb.com>
 <20180802103648.3d9f8e6d@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180802103648.3d9f8e6d@canb.auug.org.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Aug 02, 2018 at 10:36:48AM +1000, Stephen Rothwell wrote:
> Hi Roman,
> 
> On Wed, 1 Aug 2018 17:31:59 -0700 Roman Gushchin <guro@fb.com> wrote:
> >
> > Introduce the mem_cgroup_put() helper, which helps to eliminate guarding
> > memcg css release with "#ifdef CONFIG_MEMCG" in multiple places.
> > 
> > Link: http://lkml.kernel.org/r/20180623000600.5818-2-guro@fb.com
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Reviewed-by: Shakeel Butt <shakeelb@google.com>
> > Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Acked-by: Michal Hocko <mhocko@kernel.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> 
> I have no idea why my Signed-off-by is attached to this patch (or
> Andrew's for that matter) ...

Hi Stephen!

I've cherry-picked this patch from the next tree,
so it got your signed-off-by.

Sorry for that!

Thanks!

Roman
