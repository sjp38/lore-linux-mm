Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 99B266B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 03:54:47 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so16962304pac.11
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 00:54:47 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id qg8si52512071pac.18.2014.12.29.00.54.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Dec 2014 00:54:46 -0800 (PST)
Date: Mon, 29 Dec 2014 11:54:35 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC PATCH 2/2] memcg: add memory and swap knobs to the default
 cgroup hierarchy
Message-ID: <20141229085435.GC9984@esperanza>
References: <dd99dc0de2ce6fd9aa18b25851819b71a58dca7d.1419782051.git.vdavydov@parallels.com>
 <9aeed65ee700e81abde90c20570415a40acb36e2.1419782051.git.vdavydov@parallels.com>
 <20141228203023.GB9385@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20141228203023.GB9385@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sun, Dec 28, 2014 at 03:30:23PM -0500, Johannes Weiner wrote:
> As such, my proposals would be:
> 
>   memory.low:        the expected lower end of the workload size
>   memory.high:       the expected upper end
>   memory.max:        the absolute OOM-enforced maximum size
>   memory.current:    the current size
> 
> And then, in the same vein:
> 
>   swap.max
>   swap.current
> 
> These names are short, but they should be unambiguous and descriptive
> in their context, and users will have to consult the documentation on
> how to configure this stuff anyway.

To me, memory.max resembles memory.max_usage_in_bytes from the old
interface, which is confusing. However, if we forget about the old
interface, the new names look fine.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
