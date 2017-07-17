Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC1CE6B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 10:46:22 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id g2so73910417qta.14
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 07:46:22 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id i44si15403085qti.263.2017.07.17.07.46.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 07:46:19 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id 19so2597291qty.1
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 07:46:19 -0700 (PDT)
Date: Mon, 17 Jul 2017 10:46:16 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 02/10] percpu: change the format for percpu_stats output
Message-ID: <20170717144616.GE3519177@devbig577.frc2.facebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-3-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170716022315.19892-3-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

On Sat, Jul 15, 2017 at 10:23:07PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> This makes the debugfs output for percpu_stats a little easier
> to read by changing the spacing of the output to be consistent.
> 
> Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>

Applied to percpu/for-4.14.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
