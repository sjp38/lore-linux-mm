Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id CD69E6B0071
	for <linux-mm@kvack.org>; Fri, 29 May 2015 09:11:00 -0400 (EDT)
Received: by qgdy38 with SMTP id y38so3891517qgd.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 06:11:00 -0700 (PDT)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id jz8si5538119qcb.35.2015.05.29.06.10.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 06:10:59 -0700 (PDT)
Received: by qkhg32 with SMTP id g32so44618500qkh.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 06:10:59 -0700 (PDT)
Date: Fri, 29 May 2015 09:10:55 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150529131055.GH27479@htj.duckdns.org>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
 <1432641006-8025-4-git-send-email-mhocko@suse.cz>
 <20150526141011.GA11065@cmpxchg.org>
 <20150528210742.GF27479@htj.duckdns.org>
 <20150529120838.GC22728@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150529120838.GC22728@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, May 29, 2015 at 02:08:38PM +0200, Michal Hocko wrote:
> > I suppose that making mm always follow the threadgroup leader should
> > be fine, right? 
> 
> That is the plan.

Cool.

> > While this wouldn't make any difference in the unified hierarchy,
> 
> Just to make sure I understand. "wouldn't make any difference" because
> the API is not backward compatible right?

Hmm... because it's always per-process.  If any thread is going, the
whole process is going together.

> > I think this would make more sense for traditional hierarchies.
> 
> Yes I believe so.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
