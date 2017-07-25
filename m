Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5266B02C3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:04:00 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o124so52554718qke.9
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:04:00 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id j4si12321942qkh.52.2017.07.25.11.03.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:03:59 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id i19so4975387qte.1
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:03:59 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:03:57 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v2 01/23] percpu: setup_first_chunk enforce dynamic
 region must exist
Message-ID: <20170725180356.GA18880@destiny>
References: <20170724230220.21774-1-dennisz@fb.com>
 <20170724230220.21774-2-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724230220.21774-2-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

On Mon, Jul 24, 2017 at 07:01:58PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> The first chunk is handled as a special case as it is composed of the
> static, reserved, and dynamic regions. The code handles each case
> individually. The next several patches will merge these code paths and
> lay the foundation for the bitmap allocator.
> 
> This patch modifies logic to enforce that a dynamic region exists and
> changes the area map to account for that. This brings the logic closer
> to the dynamic chunk's init logic.
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
