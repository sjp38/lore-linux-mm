Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3A35382F7F
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 15:50:47 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so43173277wic.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 12:50:45 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id eq6si1197760wjd.12.2015.09.24.12.50.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 12:50:44 -0700 (PDT)
Date: Thu, 24 Sep 2015 15:50:21 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm/vmscan: make inactive_anon/file_is_low return bool
Message-ID: <20150924195021.GC3009@cmpxchg.org>
References: <1442842673-4140-1-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442842673-4140-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mhocko@kernel.org, rientjes@google.com, vdavydov@parallels.com, oleg@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 21, 2015 at 09:37:52PM +0800, Yaowei Bai wrote:
> This patch makes inactive_anon/file_is_low return bool
> due to these particular functions only using either one
> or zero as their return value.
> 
> No functional change.
> 
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

You can probably merge both patches into a single commit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
