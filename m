Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1E26B02FD
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:10:55 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l13so25689294qtc.15
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:10:55 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id t53si5515492qtc.261.2017.07.25.11.10.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:10:54 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id d136so13371172qkg.3
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:10:54 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:10:53 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 05/23] percpu: unify allocation of schunk and dchunk
Message-ID: <20170725181052.GE18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-6-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-6-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:02PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> Create a common allocator for first chunk initialization,
> pcpu_alloc_first_chunk. Comments for this function will be added in a
> later patch once the bitmap allocator is added.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
> ---

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
