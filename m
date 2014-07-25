Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3549C6B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 11:43:25 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hi2so1221998wib.11
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:43:24 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id v3si3275664wix.58.2014.07.25.08.43.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 08:43:23 -0700 (PDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so1313306wiv.0
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:43:23 -0700 (PDT)
Date: Fri, 25 Jul 2014 17:43:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140725154320.GB18303@dhcp22.suse.cz>
References: <20140719173911.GA1725@cmpxchg.org>
 <20140722150825.GA4517@dhcp22.suse.cz>
 <CAJfpegscT-ptQzq__uUV2TOn7Uvs6x4FdWGTQb9Fe9MEJr2KjA@mail.gmail.com>
 <20140723143847.GB16721@dhcp22.suse.cz>
 <20140723150608.GF1725@cmpxchg.org>
 <CAJfpegs-k5QC+42SzLKUSaHrdPxWBaT_dF+SOPqoDvg8h5p_Tw@mail.gmail.com>
 <20140723210241.GH1725@cmpxchg.org>
 <20140724084644.GA14578@dhcp22.suse.cz>
 <20140724090257.GB14578@dhcp22.suse.cz>
 <20140725152654.GK1725@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140725152654.GK1725@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri 25-07-14 11:26:54, Johannes Weiner wrote:
> On Thu, Jul 24, 2014 at 11:02:57AM +0200, Michal Hocko wrote:
> > On Thu 24-07-14 10:46:44, Michal Hocko wrote:
> > > On Wed 23-07-14 17:02:41, Johannes Weiner wrote:
> > [...]
> > > We can reduce the lookup only to lruvec==true case, no?
> > 
> > Dohh
> > s@can@should@
> > 
> > newpage shouldn't charged in all other cases and it would be bug.
> > Or am I missing something?
> 
> Yeah, but I'd hate to put that assumption onto the @lrucare parameter,
> it just coincides.

Yes, you are right. Maybe replace_page_cache_page should have it's own
memcg variant which does all the trickery and then call
mem_cgroup_migrate when necessary...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
