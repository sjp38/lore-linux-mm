Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9266B0078
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 18:36:19 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id l13so6181405iga.15
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 15:36:18 -0800 (PST)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com. [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id p10si28390701ict.94.2014.11.03.15.36.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 15:36:18 -0800 (PST)
Received: by mail-ie0-f176.google.com with SMTP id rd18so6163657iec.7
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 15:36:17 -0800 (PST)
Date: Mon, 3 Nov 2014 15:36:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC patch] mm: hugetlb: fix __unmap_hugepage_range
In-Reply-To: <028701cff4c2$3e9e2ca0$bbda85e0$@alibaba-inc.com>
Message-ID: <alpine.DEB.2.10.1411031536040.7733@chino.kir.corp.google.com>
References: <028701cff4c2$3e9e2ca0$bbda85e0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, 31 Oct 2014, Hillf Danton wrote:

> First, after flushing TLB, we have no need to scan pte from start again.
> Second, before bail out loop, the address is forwarded one step.
> 
> Signed-off-by: Hillf Danton <hillf.zj@alibaba-inc.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
