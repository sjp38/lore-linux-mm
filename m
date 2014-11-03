Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 55C6E6B00FF
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 12:31:02 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so12576168pac.2
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 09:31:02 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rp1si15675530pbc.214.2014.11.03.09.31.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 09:31:01 -0800 (PST)
Date: Mon, 3 Nov 2014 20:30:54 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 2/3] mm: page_cgroup: rename file to mm/swap_cgroup.c
Message-ID: <20141103173053.GV17258@esperanza>
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org>
 <1414898156-4741-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1414898156-4741-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Nov 01, 2014 at 11:15:55PM -0400, Johannes Weiner wrote:
> Now that the external page_cgroup data structure and its lookup is
> gone, the only code remaining in there is swap slot accounting.
> 
> Rename it and move the conditional compilation into mm/Makefile.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
