Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6AC6B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 10:44:55 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 19so73722464qty.2
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 07:44:55 -0700 (PDT)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id g6si6391303qkc.238.2017.07.17.07.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 07:44:54 -0700 (PDT)
Received: by mail-qk0-x22b.google.com with SMTP id d78so121917256qkb.1
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 07:44:54 -0700 (PDT)
Date: Mon, 17 Jul 2017 10:44:51 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 01/10] percpu: pcpu-stats change void buffer to int buffer
Message-ID: <20170717144451.GD3519177@devbig577.frc2.facebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-2-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170716022315.19892-2-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

On Sat, Jul 15, 2017 at 10:23:06PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> Changes the use of a void buffer to an int buffer for clarity.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Applied to percpu/for-4.14.h

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
