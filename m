Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 341D56B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:25:03 -0500 (EST)
Received: by wmnn186 with SMTP id n186so45227197wmn.0
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:25:02 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p190si6974197wmg.80.2015.12.11.11.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 11:25:02 -0800 (PST)
Date: Fri, 11 Dec 2015 14:24:47 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/7] mm: vmscan: pass memcg to get_scan_count()
Message-ID: <20151211192446.GA3773@cmpxchg.org>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <587fef1387d133d77c219c03e7aa371889893c57.1449742560.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <587fef1387d133d77c219c03e7aa371889893c57.1449742560.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 10, 2015 at 02:39:15PM +0300, Vladimir Davydov wrote:
> memcg will come in handy in get_scan_count(). It can already be used for
> getting swappiness immediately in get_scan_count() instead of passing it
> around. The following patches will add more memcg-related values, which
> will be used there.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
