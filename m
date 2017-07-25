Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 464436B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 15:25:06 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o124so53464116qke.9
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:25:06 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id u24si11877797qta.66.2017.07.25.12.25.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 12:25:05 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id q66so13551971qki.1
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:25:05 -0700 (PDT)
Date: Tue, 25 Jul 2017 15:25:04 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 17/23] percpu: skip chunks if the alloc does not fit
 in the contig hint
Message-ID: <20170725192503.GQ18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-18-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-18-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:14PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> This patch adds chunk->contig_bits_start to keep track of the contig
> hint's offset and the check to skip the chunk if it does not fit. If
> the chunk's contig hint starting offset cannot satisfy an allocation,
> the allocator assumes there is enough memory pressure in this chunk to
> either use a different chunk or create a new one. This accepts a less
> tight packing for a smoother latency curve.
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
