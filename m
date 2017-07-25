Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C13156B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:35:18 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d136so24666800qkg.11
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:35:18 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id v4si11465684qtb.16.2017.07.25.11.35.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:35:18 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id v76so1844822qka.5
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:35:18 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:35:16 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 13/23] percpu: generalize bitmap (un)populated
 iterators
Message-ID: <20170725183515.GM18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-14-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-14-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

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

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
