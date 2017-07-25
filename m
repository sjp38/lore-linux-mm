Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB3B6B02FD
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:14:33 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o65so65438950qkl.12
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:14:33 -0700 (PDT)
Received: from mail-qk0-x22a.google.com (mail-qk0-x22a.google.com. [2607:f8b0:400d:c09::22a])
        by mx.google.com with ESMTPS id t185si11513675qkc.252.2017.07.25.11.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:14:33 -0700 (PDT)
Received: by mail-qk0-x22a.google.com with SMTP id k2so35244425qkf.0
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:14:33 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:14:31 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 06/23] percpu: end chunk area maps page aligned for
 the populated bitmap
Message-ID: <20170725181431.GF18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-7-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-7-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:03PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> The area map allocator manages the first chunk area by hiding all but
> the region it is responsible for serving in the area map. To align this
> with the populated page bitmap, end_offset is introduced to keep track
> of the delta to end page aligned. The area map is appended with the
> page aligned end when necessary to be in line with how the bitmap
> allocator requires the ending to be aligned with the LCM of PAGE_SIZE
> and the size of each bitmap block. percpu_stats is updated to ignore
> this region when present.
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
