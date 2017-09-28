Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA57C6B0261
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 10:41:01 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id b23so667454qkg.4
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 07:41:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c7sor1093952qkj.19.2017.09.28.07.41.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 07:41:00 -0700 (PDT)
Date: Thu, 28 Sep 2017 07:40:51 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] percpu: fix iteration to prevent skipping over block
Message-ID: <20170928144051.GC15129@devbig577.frc2.facebook.com>
References: <1506548100-31247-1-git-send-email-dennisszhou@gmail.com>
 <1506548100-31247-3-git-send-email-dennisszhou@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506548100-31247-3-git-send-email-dennisszhou@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisszhou@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Luis Henriques <lhenriques@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 27, 2017 at 04:35:00PM -0500, Dennis Zhou wrote:
> The iterator functions pcpu_next_md_free_region and
> pcpu_next_fit_region use the block offset to determine if they have
> checked the area in the prior iteration. However, this causes an issue
> when the block offset is greater than subsequent block contig hints. If
> within the iterator it moves to check subsequent blocks, it may fail in
> the second predicate due to the block offset not being cleared. Thus,
> this causes the allocator to skip over blocks leading to false failures
> when allocating from the reserved chunk. While this happens in the
> general case as well, it will only fail if it cannot allocate a new
> chunk.
> 
> This patch resets the block offset to 0 to pass the second predicate
> when checking subseqent blocks within the iterator function.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
> Reported-by: Luis Henriques <lhenriques@suse.com>

Applied to percpu/for-4.14-fixes.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
