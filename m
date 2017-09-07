Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BDEED6B031F
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 16:39:13 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q77so1054913qke.4
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 13:39:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y14sor141354qta.61.2017.09.07.13.39.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Sep 2017 13:39:12 -0700 (PDT)
Date: Thu, 7 Sep 2017 13:39:09 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] idr: remove WARN_ON_ONCE() when trying to replace
 negative ID
Message-ID: <20170907203909.GV1774378@devbig577.frc2.facebook.com>
References: <20170906235306.20534-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170906235306.20534-1-ebiggers3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Dmitry Vyukov <dvyukov@google.com>, Matthew Wilcox <mawilcox@microsoft.com>, dri-devel@lists.freedesktop.org, stable@vger.kernel.org

On Wed, Sep 06, 2017 at 04:53:06PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> IDR only supports non-negative IDs.  There used to be a
> 'WARN_ON_ONCE(id < 0)' in idr_replace(), but it was intentionally
> removed by commit 2e1c9b286765 ("idr: remove WARN_ON_ONCE() on negative
> IDs").  Then it was added back by commit 0a835c4f090a ("Reimplement IDR
> and IDA using the radix tree").  However it seems that adding it back
> was a mistake, given that some users such as drm_gem_handle_delete()
> (DRM_IOCTL_GEM_CLOSE) pass in a value from userspace to idr_replace(),
> allowing the WARN_ON_ONCE to be triggered.  drm_gem_handle_delete()
> actually just wants idr_replace() to return an error code if the ID is
> not allocated, including in the case where the ID is invalid (negative).

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
