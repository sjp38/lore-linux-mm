Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id A9D266B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:33:54 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id s18so75831646qks.4
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:33:54 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id s13si11641770qki.511.2017.07.25.11.33.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:33:53 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id i19so5046451qte.1
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:33:53 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:33:52 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 12/23] percpu: increase minimum percpu allocation size
 and align first regions
Message-ID: <20170725183351.GL18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-13-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-13-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:09PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> This patch increases the minimum allocation size of percpu memory to
> 4-bytes. This change will help minimize the metadata overhead
> associated with the bitmap allocator. The assumption is that most
> allocations will be of objects or structs greater than 2 bytes with
> integers or longs being used rather than shorts.
> 
> The first chunk regions are now aligned with the minimum allocation
> size. The reserved region is expected to be set as a multiple of the
> minimum allocation size. The static region is aligned up and the delta
> is removed from the dynamic size. This works because the dynamic size is
> increased to be page aligned. If the static size is not minimum
> allocation size aligned, then there must be a gap that is added to the
> dynamic size. The dynamic size will never be smaller than the set value.
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
