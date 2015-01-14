Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3E6A96B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 09:28:53 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so10796245pab.7
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 06:28:53 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id c8si30988861pat.105.2015.01.14.06.28.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jan 2015 06:28:51 -0800 (PST)
Date: Wed, 14 Jan 2015 17:28:41 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 2/2] mm: memcontrol: default hierarchy interface for
 memory
Message-ID: <20150114142841.GE11264@esperanza>
References: <1420776904-8559-1-git-send-email-hannes@cmpxchg.org>
 <1420776904-8559-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1420776904-8559-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jan 08, 2015 at 11:15:04PM -0500, Johannes Weiner wrote:
>   - memory.low configures the lower end of the cgroup's expected
>     memory consumption range.  The kernel considers memory below that
>     boundary to be a reserve - the minimum that the workload needs in
>     order to make forward progress - and generally avoids reclaiming
>     it, unless there is an imminent risk of entering an OOM situation.

AFAICS, if a cgroup cannot be shrunk back to its low limit (e.g.
because it consumes anon memory, and there's no swap), it will get on
with it. Is it considered to be a problem? Are there any plans to fix
it, e.g. by invoking OOM-killer in a cgroup that is above its low limit
if we fail to reclaim from it?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
