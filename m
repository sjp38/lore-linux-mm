Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 846236B02F3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:04:20 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q1so76040470qkb.3
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:04:20 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id 73si12280341qkx.330.2017.07.25.11.04.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:04:19 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id u19so2391466qtc.0
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:04:19 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:04:18 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 02/23] percpu: introduce start_offset to pcpu_chunk
Message-ID: <20170725180417.GB18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-3-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-3-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:01:59PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> The reserved chunk arithmetic uses a global variable
> pcpu_reserved_chunk_limit that is set in the first chunk init code to
> hide a portion of the area map. The bitmap allocator to come will
> eventually move the base_addr up and require both the reserved chunk
> and static chunk to maintain this offset. pcpu_reserved_chunk_limit is
> removed and start_offset is added.
> 
> The first chunk that is circulated and is pcpu_first_chunk serves the
> dynamic region, the region following the reserved region. The reserved
> chunk address check will temporarily use the first chunk to identify its
> address range. A following patch will increase the base_addr and remove
> this. If there is no reserved chunk, this will check the static region
> and return false because those values should never be passed into the
> allocator.
> 
> Lastly, when linking in the first chunk, make sure to count the right
> free region for the number of empty populated pages.
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
