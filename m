Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id DEF816B0255
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 19:03:17 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so129197367pac.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:03:17 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id mj6si41071204pab.217.2015.09.21.16.03.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 16:03:17 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so131698353pac.2
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:03:17 -0700 (PDT)
Date: Mon, 21 Sep 2015 16:03:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/3] mm/compaction: add an is_via_compact_memory helper
 function
In-Reply-To: <1442404800-4051-3-git-send-email-bywxiaobai@163.com>
Message-ID: <alpine.DEB.2.10.1509211602470.27715@chino.kir.corp.google.com>
References: <1442404800-4051-1-git-send-email-bywxiaobai@163.com> <1442404800-4051-3-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mhocko@kernel.org, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 16 Sep 2015, Yaowei Bai wrote:

> Introduce is_via_compact_memory helper function indicating compacting
> via /proc/sys/vm/compact_memory to improve readability.
> 
> To catch this situation in __compaction_suitable, use order as parameter
> directly instead of using struct compact_control.
> 
> This patch has no functional changes.
> 
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks for doing these cleanups!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
