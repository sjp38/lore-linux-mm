Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B14C06B0033
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 17:24:25 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g202so7449651ita.4
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 14:24:25 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b81sor7521053itb.145.2017.11.20.14.24.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Nov 2017 14:24:23 -0800 (PST)
Date: Mon, 20 Nov 2017 14:24:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 1/3] mm/mempolicy: remove redundant check in
 get_nodes
In-Reply-To: <1510882624-44342-2-git-send-email-xieyisheng1@huawei.com>
Message-ID: <alpine.DEB.2.10.1711201424100.42955@chino.kir.corp.google.com>
References: <1510882624-44342-1-git-send-email-xieyisheng1@huawei.com> <1510882624-44342-2-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, ak@linux.intel.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, tanxiaojun@huawei.com

On Fri, 17 Nov 2017, Yisheng Xie wrote:

> We have already checked whether maxnode is a page worth of bits, by:
>     maxnode > PAGE_SIZE*BITS_PER_BYTE
> 
> So no need to check it once more.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
