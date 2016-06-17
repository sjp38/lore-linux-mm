Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A55FB6B007E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 14:17:26 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y77so142737784qkb.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 11:17:26 -0700 (PDT)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id 63si9171832ywr.144.2016.06.17.11.17.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 11:17:25 -0700 (PDT)
Received: by mail-yw0-x241.google.com with SMTP id g20so342296ywb.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 11:17:25 -0700 (PDT)
Date: Fri, 17 Jun 2016 14:17:24 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] cgroup: remove unnecessary 0 check from css_from_id()
Message-ID: <20160617181724.GO3262@mtj.duckdns.org>
References: <20160616034244.14839-1-hannes@cmpxchg.org>
 <20160616200617.GD3262@mtj.duckdns.org>
 <20160617162310.GA19084@cmpxchg.org>
 <20160617162427.GC19084@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160617162427.GC19084@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Jun 17, 2016 at 12:24:27PM -0400, Johannes Weiner wrote:
> css_idr allocation starts at 1, so index 0 will never point to an
> item. css_from_id() currently filters that before asking idr_find(),
> but idr_find() would also just return NULL, so this is not needed.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Applied 1-2 to cgroup/for-4.8.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
