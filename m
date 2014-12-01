Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 357866B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 18:23:53 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id a1so7314641wgh.19
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 15:23:52 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u2si47432932wiw.103.2014.12.01.15.23.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 15:23:52 -0800 (PST)
Date: Mon, 1 Dec 2014 18:23:43 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, oom: remove gfp helper function
Message-ID: <20141201232343.GA29642@phnom.home.cmpxchg.org>
References: <alpine.DEB.2.10.1411261416480.13014@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1411261416480.13014@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Qiang Huang <h.huangqiang@huawei.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 26, 2014 at 02:17:32PM -0800, David Rientjes wrote:
> Commit b9921ecdee66 ("mm: add a helper function to check may oom
> condition") was added because the gfp criteria for oom killing was
> checked in both the page allocator and memcg.
> 
> That was true for about nine months, but then commit 0029e19ebf84 ("mm:
> memcontrol: remove explicit OOM parameter in charge path") removed the
> memcg usecase.
> 
> Fold the implementation into its only caller.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
