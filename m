Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 09A716B0038
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 19:01:15 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so128942101pad.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:01:14 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id km1si41105404pab.52.2015.09.21.16.01.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 16:01:14 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so129152904pac.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:01:14 -0700 (PDT)
Date: Mon, 21 Sep 2015 16:01:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm/vmscan: make inactive_anon_is_low_global return
 directly
In-Reply-To: <1442404800-4051-1-git-send-email-bywxiaobai@163.com>
Message-ID: <alpine.DEB.2.10.1509211601010.27715@chino.kir.corp.google.com>
References: <1442404800-4051-1-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mhocko@kernel.org, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, zhangyanfei@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 16 Sep 2015, Yaowei Bai wrote:

> Delete unnecessary if to let inactive_anon_is_low_global return
> directly.
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
