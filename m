Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB8E6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 15:43:16 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f126so25165352wma.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 12:43:16 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c9si4579714wju.177.2016.07.07.12.43.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 12:43:14 -0700 (PDT)
Date: Thu, 7 Jul 2016 15:40:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH rebase] mm: fix vm-scalability regression in cgroup-aware
 workingset code
Message-ID: <20160707194024.GA26580@cmpxchg.org>
References: <20160622182019.24064-1-hannes@cmpxchg.org>
 <20160624175101.GA3024@cmpxchg.org>
 <20160627130527.GK31799@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160627130527.GK31799@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ye Xiaolong <xiaolong.ye@intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi Michal,

[sorry for the delay, I was traveling with no connectivity]

On Mon, Jun 27, 2016 at 03:05:28PM +0200, Michal Hocko wrote:
> On Fri 24-06-16 13:51:01, Johannes Weiner wrote:
>
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> Minor note below
> 
> > +static inline struct mem_cgroup *page_memcg_rcu(struct page *page)
> > +{
> 
> I guess rcu_read_lock_held() here would be appropriate
> 
> > +	return READ_ONCE(page->mem_cgroup);

Agreed.

Andrew, could you please fold this?
