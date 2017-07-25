Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 49C046B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:29:27 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d136so24595776qkg.11
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:29:27 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id u19si11253593qkl.321.2017.07.25.11.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:29:26 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id d136so13417191qkg.3
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:29:26 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:29:25 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 11/23] percpu: introduce nr_empty_pop_pages to help
 empty page accounting
Message-ID: <20170725182924.GK18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-12-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-12-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:08PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> pcpu_nr_empty_pop_pages is used to ensure there are a handful of free
> pages around to serve atomic allocations. A new field, nr_empty_pop_pages,
> is added to the pcpu_chunk struct to keep track of the number of empty
> pages. This field is needed as the number of empty populated pages is
> globally tracked and deltas are used to update in the bitmap allocator.
> Pages that contain a hidden area are not considered to be empty. This
> new field is exposed in percpu_stats.
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
