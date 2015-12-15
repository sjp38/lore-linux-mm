Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8290C6B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 16:27:22 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id n186so114433362wmn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 13:27:22 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id kd10si4736588wjc.145.2015.12.15.13.27.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 13:27:21 -0800 (PST)
Date: Tue, 15 Dec 2015 16:26:39 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: mempool: Factor out mempool_refill()
Message-ID: <20151215212638.GA17162@cmpxchg.org>
References: <1449978390-10931-1-git-send-email-zhi.a.wang@intel.com>
 <F3B0350DF4CB6849A642218320DE483D4B866043@SHSMSX101.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F3B0350DF4CB6849A642218320DE483D4B866043@SHSMSX101.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Zhi A" <zhi.a.wang@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>

On Mon, Dec 14, 2015 at 11:09:43AM +0000, Wang, Zhi A wrote:
> This patch factors out mempool_refill() from mempool_resize(). It's reasonable
> that the mempool user wants to refill the pool immdiately when it has chance
> e.g. inside a sleepible context, so that next time in the IRQ context the pool
> would have much more available elements to allocate.
> 
> After the refactor, mempool_refill() can also executes with mempool_resize()
> /mempool_alloc/mempool_free() or another mempool_refill().
> 
> Signed-off-by: Zhi Wang <zhi.a.wang@intel.com>

Who is going to call that function? Adding a new interace usually
comes with a user, or as part of a series that adds users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
