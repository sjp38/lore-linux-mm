Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 097CF6B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 17:46:31 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o3so16199491qte.7
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 14:46:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 10sor6444945qtq.8.2017.09.27.14.46.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Sep 2017 14:46:30 -0700 (PDT)
Date: Wed, 27 Sep 2017 14:46:27 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/2] percpu: fix starting offset for chunk statistics
 traversal
Message-ID: <20170927214627.GA15129@devbig577.frc2.facebook.com>
References: <1506548100-31247-1-git-send-email-dennisszhou@gmail.com>
 <1506548100-31247-2-git-send-email-dennisszhou@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506548100-31247-2-git-send-email-dennisszhou@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisszhou@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Luis Henriques <lhenriques@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 27, 2017 at 04:34:59PM -0500, Dennis Zhou wrote:
> This patch fixes the starting offset used when scanning chunks to
> compute the chunk statistics. The value start_offset (and end_offset)
> are managed in bytes while the traversal occurs over bits. Thus for the
> reserved and dynamic chunk, it may incorrectly skip over the initial
> allocations.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Applied to percpu/for-4.14-fixes.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
