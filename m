Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52A526B0006
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 16:41:52 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id g7so889439qkd.14
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:41:52 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u5sor2300452qta.52.2018.02.15.13.41.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Feb 2018 13:41:51 -0800 (PST)
Date: Thu, 15 Feb 2018 13:41:48 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] percpu: allow select gfp to be passed to underlying
 allocators
Message-ID: <20180215214148.GV695913@devbig577.frc2.facebook.com>
References: <cover.1518668149.git.dennisszhou@gmail.com>
 <a166972c727e3a1235a7ad17b9df94ca407a1548.1518668149.git.dennisszhou@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a166972c727e3a1235a7ad17b9df94ca407a1548.1518668149.git.dennisszhou@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisszhou@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Daniel Borkmann <daniel@iogearbox.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Thu, Feb 15, 2018 at 10:08:16AM -0600, Dennis Zhou wrote:
> +/* the whitelisted flags that can be passed to the backing allocators */
> +#define gfp_percpu_mask(gfp) (((gfp) & (__GFP_NORETRY | __GFP_NOWARN)) | \
> +			      GFP_KERNEL)

Isn't there just one place where gfp comes in from outside?  If so,
this looks like a bit of overkill.  Can't we just filter there?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
