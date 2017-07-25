Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 168A76B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 15:47:47 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l55so83352565qtl.7
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:47:47 -0700 (PDT)
Received: from mail-qt0-x232.google.com (mail-qt0-x232.google.com. [2607:f8b0:400d:c0d::232])
        by mx.google.com with ESMTPS id s2si6679524qkb.42.2017.07.25.12.47.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 12:47:46 -0700 (PDT)
Received: by mail-qt0-x232.google.com with SMTP id s6so44955040qtc.1
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 12:47:45 -0700 (PDT)
Date: Tue, 25 Jul 2017 15:47:44 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 22/23] percpu: update pcpu_find_block_fit to use an
 iterator
Message-ID: <20170725194744.GV18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-23-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-23-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:19PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> The simple, and expensive, way to find a free area is to iterate over
> the entire bitmap until an area is found that fits the allocation size
> and alignment. This patch makes use of an iterate that find an area to
> check by using the block level contig hints. It will only return an area
> that can fit the size and alignment request. If the request can fit
> inside a block, it returns the first_free bit to start checking from to
> see if it can be fulfilled prior to the contig hint. The pcpu_alloc_area
> check has a bound of a block size added in case it is wrong.
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
