Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id AAE6A6B0265
	for <linux-mm@kvack.org>; Sat, 14 Nov 2015 11:33:33 -0500 (EST)
Received: by lfaz4 with SMTP id z4so3942904lfa.0
        for <linux-mm@kvack.org>; Sat, 14 Nov 2015 08:33:32 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id mt4si19072788lbb.7.2015.11.14.08.33.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Nov 2015 08:33:31 -0800 (PST)
Date: Sat, 14 Nov 2015 19:33:10 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 05/14] net: tcp_memcontrol: protect all tcp_memcontrol
 calls by jump-label
Message-ID: <20151114163309.GL31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1447371693-25143-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 12, 2015 at 06:41:24PM -0500, Johannes Weiner wrote:
> Move the jump-label from sock_update_memcg() and sock_release_memcg()
> to the callsite, and so eliminate those function calls when socket
> accounting is not enabled.

I don't believe this patch's necessary, because these functions aren't
hot paths. Neither do I think it makes the code look better. Anyway,
it's rather a matter of personal preference, and the patch looks correct
to me, so

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

> 
> This also eliminates the need for dummy functions because the calls
> will be optimized away if the Kconfig options are not enabled.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
