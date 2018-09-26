Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE178E0001
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 20:24:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e85-v6so6281010pfk.1
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 17:24:43 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id go1si3715442plb.266.2018.09.25.17.24.41
        for <linux-mm@kvack.org>;
        Tue, 25 Sep 2018 17:24:42 -0700 (PDT)
Date: Wed, 26 Sep 2018 10:24:39 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 8/8] btrfs: drop mmap_sem in mkwrite for btrfs
Message-ID: <20180926002439.GB18567@dastard>
References: <20180925153011.15311-1-josef@toxicpanda.com>
 <20180925153011.15311-9-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180925153011.15311-9-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, riel@redhat.com, hannes@cmpxchg.org, tj@kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, Sep 25, 2018 at 11:30:11AM -0400, Josef Bacik wrote:
> @@ -1454,6 +1463,11 @@ static inline int fixup_user_fault(struct task_struct *tsk,
>  	BUG();
>  	return -EFAULT;
>  }
> +stiatc inline struct file *maybe_unlock_mmap_for_io(struct vm_area_struct *vma,
> +						    int flags)
> +{
> +	return NULL;
> +}

This doesn't compile either.

-Dave.
-- 
Dave Chinner
david@fromorbit.com
