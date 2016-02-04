Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9758D4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 15:53:01 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id 128so44961165wmz.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 12:53:01 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j127si22596516wmb.11.2016.02.04.12.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 12:53:00 -0800 (PST)
Date: Thu, 4 Feb 2016 15:52:10 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] mm: memcontrol: report kernel stack usage in cgroup2
 memory.stat
Message-ID: <20160204205210.GF8208@cmpxchg.org>
References: <57ff0330b597738127ae0f9ca331016719bea7d8.1454589800.git.vdavydov@virtuozzo.com>
 <1d7473a8f8b814e536f9fdbd29d90591f1952f73.1454589800.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1d7473a8f8b814e536f9fdbd29d90591f1952f73.1454589800.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 04, 2016 at 04:03:39PM +0300, Vladimir Davydov wrote:
> Show how much memory is allocated to kernel stacks.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks, this looks good. The only thing that strikes me is that you
appended the new stat items to the enum, but then prepended them to
the doc and stat file sections. Why is that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
