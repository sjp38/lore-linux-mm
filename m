Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 608CF6B025D
	for <linux-mm@kvack.org>; Sat, 14 Nov 2015 08:23:43 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so67823780lbb.3
        for <linux-mm@kvack.org>; Sat, 14 Nov 2015 05:23:42 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id e78si18513031lfg.162.2015.11.14.05.23.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Nov 2015 05:23:41 -0800 (PST)
Date: Sat, 14 Nov 2015 16:23:25 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 11/14] mm: memcontrol: do not account memory+swap on
 unified hierarchy
Message-ID: <20151114132325.GJ31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-12-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1447371693-25143-12-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Nov 12, 2015 at 06:41:30PM -0500, Johannes Weiner wrote:
> The unified hierarchy memory controller doesn't expose the memory+swap
> counter to userspace, but its accounting is hardcoded in all charge
> paths right now, including the per-cpu charge cache ("the stock").
> 
> To avoid adding yet more pointless memory+swap accounting with the
> socket memory support in unified hierarchy, disable the counter
> altogether when in unified hierarchy mode.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
