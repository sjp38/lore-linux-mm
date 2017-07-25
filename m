Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B41196B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 15:20:59 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o65so66173705qkl.12
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:20:59 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id r125si11502874qkb.471.2017.07.25.12.20.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 12:20:59 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id q66so13542425qki.1
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:20:59 -0700 (PDT)
Date: Tue, 25 Jul 2017 15:20:57 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 15/23] percpu: introduce bitmap metadata blocks
Message-ID: <20170725192057.GO18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-16-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-16-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:12PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> This patch introduces the bitmap metadata blocks and adds the skeleton
> of the code that will be used to maintain these blocks.  Each chunk's
> bitmap is made up of full metadata blocks. These blocks maintain basic
> metadata to help prevent scanning unnecssarily to update hints. Full
> scanning methods are used for the skeleton and will be replaced in the
> coming patches. A number of helper functions are added as well to do
> conversion of pages to blocks and manage offsets. Comments will be
> updated as the final version of each function is added.
> 
> There exists a relationship between PAGE_SIZE, PCPU_BITMAP_BLOCK_SIZE,
> the region size, and unit_size. Every chunk's region (including offsets)
> is page aligned at the beginning to preserve alignment. The end is
> aligned to LCM(PAGE_SIZE, PCPU_BITMAP_BLOCK_SIZE) to ensure that the end
> can fit with the populated page map which is by page and every metadata
> block is fully accounted for. The unit_size is already page aligned, but
> must also be aligned with PCPU_BITMAP_BLOCK_SIZE to ensure full metadata
> blocks.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
