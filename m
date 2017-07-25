Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0196B02C3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:07:34 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o65so65365804qkl.12
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:07:34 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id v194si5021738qka.416.2017.07.25.11.07.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:07:33 -0700 (PDT)
Received: by mail-qk0-x22f.google.com with SMTP id d136so77408951qkg.3
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:07:33 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:07:32 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 04/23] percpu: setup_first_chunk remove dyn_size and
 consolidate logic
Message-ID: <20170725180731.GD18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-5-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-5-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:02:01PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> There is logic for setting variables in the static chunk init code that
> could be consolidated with the dynamic chunk init code. This combines
> this logic to setup for combining the allocation paths. reserved_size is
> used as the conditional as a dynamic region will always exist.
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
