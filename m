Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2297D6B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 10:29:54 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id gl10so4363780lab.18
        for <linux-mm@kvack.org>; Fri, 23 May 2014 07:29:53 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id dr3si6128745lbc.33.2014.05.23.07.29.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 May 2014 07:29:52 -0700 (PDT)
Date: Fri, 23 May 2014 18:29:31 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 7/9] mm: memcontrol: do not acquire page_cgroup lock for
 kmem pages
Message-ID: <20140523142929.GC3147@esperanza>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-8-git-send-email-hannes@cmpxchg.org>
 <20140523133938.GC22135@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140523133938.GC22135@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, May 23, 2014 at 03:39:38PM +0200, Michal Hocko wrote:
> I am adding Vladimir to CC
> 
> On Wed 30-04-14 16:25:41, Johannes Weiner wrote:
> > Kmem page charging and uncharging is serialized by means of exclusive
> > access to the page.  Do not take the page_cgroup lock and don't set
> > pc->flags atomically.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
