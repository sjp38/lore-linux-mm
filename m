Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8DF6B03A4
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 10:19:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b87so2912560wmi.14
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 07:19:08 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u68si12311153wma.137.2017.04.10.07.19.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 07:19:07 -0700 (PDT)
Date: Mon, 10 Apr 2017 10:19:01 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, swap_cgroup: reschedule when neeed in
 swap_cgroup_swapoff()
Message-ID: <20170410141901.GC16119@cmpxchg.org>
References: <alpine.DEB.2.10.1704061315270.80559@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1704061315270.80559@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Apr 06, 2017 at 01:16:24PM -0700, David Rientjes wrote:
> We got need_resched() warnings in swap_cgroup_swapoff() because
> swap_cgroup_ctrl[type].length is particularly large.
> 
> Reschedule when needed.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
