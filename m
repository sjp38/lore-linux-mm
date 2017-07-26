Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B76C6B0292
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:08:49 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d136so34989020qkg.11
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:08:49 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id e32si12616875qtb.177.2017.07.26.07.08.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 07:08:48 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id d136so15498133qkg.3
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:08:48 -0700 (PDT)
Date: Wed, 26 Jul 2017 10:08:44 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 13/23] percpu: generalize bitmap (un)populated
 iterators
Message-ID: <20170726140844.GB742618@devbig577.frc2.facebook.com>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-14-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-14-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:10PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> The area map allocator only used a bitmap for the backing page state.
> The new bitmap allocator will use bitmaps to manage the allocation
> region in addition to this.
> 
> This patch generalizes the bitmap iterators so they can be reused with
> the bitmap allocator.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Applied 1-13 to percpu/for-4.14.

Nice cleanups.  Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
