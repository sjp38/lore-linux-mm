Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C082280250
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 04:00:37 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id i193so187468840oib.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 01:00:37 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id o133si363803oif.18.2016.09.22.01.00.35
        for <linux-mm@kvack.org>;
        Thu, 22 Sep 2016 01:00:36 -0700 (PDT)
Date: Thu, 22 Sep 2016 17:01:24 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 5/7] slab, workqueue: remove keventd_up() usage
Message-ID: <20160922080124.GA30663@js1304-P5Q-DELUXE>
References: <1473967821-24363-1-git-send-email-tj@kernel.org>
 <1473967821-24363-6-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1473967821-24363-6-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, jiangshanlai@gmail.com, akpm@linux-foundation.org, kernel-team@fb.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Thu, Sep 15, 2016 at 03:30:19PM -0400, Tejun Heo wrote:
> Now that workqueue can handle work item queueing from very early
> during boot, there is no need to gate schedule_delayed_work_on() while
> !keventd_up().  Remove it.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> ---
> Hello,
> 
> This change depends on an earlier workqueue patch and is followed by a
> patch to remove keventd_up().  It'd be great if it can be routed
> through the wq/for-4.9 branch.

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
