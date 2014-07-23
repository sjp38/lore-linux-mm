Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id C34B96B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 11:19:37 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so1308603wgh.2
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 08:19:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u9si5804046wiy.4.2014.07.23.08.19.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 08:19:26 -0700 (PDT)
Date: Wed, 23 Jul 2014 17:19:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140723151909.GC16721@dhcp22.suse.cz>
References: <20140715082545.GA9366@dhcp22.suse.cz>
 <20140715121935.GB9366@dhcp22.suse.cz>
 <20140718071246.GA21565@dhcp22.suse.cz>
 <20140718144554.GG29639@cmpxchg.org>
 <CAJfpegt9k+YULet3vhmG3br7zSiHy-DRL+MiEE=HRzcs+mLzbw@mail.gmail.com>
 <20140719173911.GA1725@cmpxchg.org>
 <20140722150825.GA4517@dhcp22.suse.cz>
 <CAJfpegscT-ptQzq__uUV2TOn7Uvs6x4FdWGTQb9Fe9MEJr2KjA@mail.gmail.com>
 <20140723143847.GB16721@dhcp22.suse.cz>
 <20140723150608.GF1725@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140723150608.GF1725@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed 23-07-14 11:06:08, Johannes Weiner wrote:
> On Wed, Jul 23, 2014 at 04:38:47PM +0200, Michal Hocko wrote:
[...]
> > OK, thanks for the clarification. I had this feeling but couldn't wrap
> > my head around the indirection of the code.
> > 
> > It seems that checkig PageCgroupUsed(new) and bail out early in
> > mem_cgroup_migrate should just work, no?
> 
> If the new page is already charged as page cache, we could just drop
> the call to mem_cgroup_migrate() altogether.

Yeah, it is just that we do not want to do all the
page->page_cgroup->PageCgroupUsed thing in replace_page_cache_page.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
