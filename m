Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B84EF6B00DD
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 03:39:41 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so13991225pad.21
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 00:39:41 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id ni10si11189037pbc.157.2014.11.04.00.39.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 00:39:40 -0800 (PST)
Received: from kw-mxq.gw.nic.fujitsu.com (unknown [10.0.237.131])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3438A3EE125
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:39:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 43BF6AC04BE
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:39:38 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E28BFE08007
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:39:37 +0900 (JST)
Message-ID: <545890B5.3020102@jp.fujitsu.com>
Date: Tue, 4 Nov 2014 17:39:17 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: move page->mem_cgroup bad page handling into
 generic code
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org> <1414898156-4741-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1414898156-4741-3-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2014/11/02 12:15), Johannes Weiner wrote:
> Now that the external page_cgroup data structure and its lookup is
> gone, let the generic bad_page() check for page->mem_cgroup sanity.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
