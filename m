Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E4FC36B0263
	for <linux-mm@kvack.org>; Mon, 23 May 2016 08:08:22 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 81so26788399wms.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 05:08:22 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id o2si15650605wma.8.2016.05.23.05.08.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 05:08:21 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id 67so14347147wmg.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 05:08:21 -0700 (PDT)
Date: Mon, 23 May 2016 14:08:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: fix the return in mem_cgroup_margin
Message-ID: <20160523120820.GQ2278@dhcp22.suse.cz>
References: <1463556255-31892-1-git-send-email-roy.qing.li@gmail.com>
 <20160518073253.GC21654@dhcp22.suse.cz>
 <CAJFZqHwFtZa-Ec_0bie6ORTrgoW1kqGsq49-=ojsT-uyNUBhwg@mail.gmail.com>
 <20160523103758.GB7917@esperanza>
 <20160523120620.GP2278@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160523120620.GP2278@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li RongQing <roy.qing.li@gmail.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Mon 23-05-16 14:06:20, Michal Hocko wrote:
[...]
> I have completely missed a potential interaction with
> __GFP_NOFAIL. We even do not seem to trigger the memcg OOM killer for
> these requests to sort the situation out.

Which is intentional. a0d8b00a3381 ("mm: memcg: do not declare OOM from
__GFP_NOFAIL allocations")

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
