Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id C81EC6B0038
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 19:02:29 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so135133084ioi.2
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:02:29 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id om6si10364630igb.48.2015.09.21.16.02.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 16:02:29 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so129180139pac.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:02:29 -0700 (PDT)
Date: Mon, 21 Sep 2015 16:02:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm/oom_kill: introduce is_sysrq_oom helper
In-Reply-To: <1442404800-4051-2-git-send-email-bywxiaobai@163.com>
Message-ID: <alpine.DEB.2.10.1509211602060.27715@chino.kir.corp.google.com>
References: <1442404800-4051-1-git-send-email-bywxiaobai@163.com> <1442404800-4051-2-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mhocko@kernel.org, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 16 Sep 2015, Yaowei Bai wrote:

> Introduce is_sysrq_oom helper function indicating oom kill triggered
> by sysrq to improve readability.
> 
> No functional changes.
> 
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
