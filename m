Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 72E4D6B0070
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 14:59:55 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id gi9so4472420lab.21
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:59:54 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kh7si15709820lbc.17.2014.10.20.11.59.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 11:59:53 -0700 (PDT)
Date: Mon, 20 Oct 2014 14:59:47 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: simplify unreclaimable groups handling in soft
 limit reclaim
Message-ID: <20141020185947.GB11973@phnom.home.cmpxchg.org>
References: <1413820554-15611-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413820554-15611-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 20, 2014 at 07:55:54PM +0400, Vladimir Davydov wrote:
> If we fail to reclaim anything from a cgroup during a soft reclaim pass
> we want to get the next largest cgroup exceeding its soft limit. To
> achieve this, we should obviously remove the current group from the tree
> and then pick the largest group. Currently we have a weird loop instead.
> Let's simplify it.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

I wonder if there will be anything left once we removed all that which
is pointless and the unnecessary from the memcg code.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
