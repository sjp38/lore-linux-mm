Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9EF06B02B4
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 10:47:15 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 19so73740771qty.2
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 07:47:15 -0700 (PDT)
Received: from mail-qt0-x22c.google.com (mail-qt0-x22c.google.com. [2607:f8b0:400d:c0d::22c])
        by mx.google.com with ESMTPS id c70si15402282qkj.133.2017.07.17.07.47.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 07:47:15 -0700 (PDT)
Received: by mail-qt0-x22c.google.com with SMTP id 21so32603981qtx.3
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 07:47:15 -0700 (PDT)
Date: Mon, 17 Jul 2017 10:47:12 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 03/10] percpu: expose pcpu_nr_empty_pop_pages in
 pcpu_stats
Message-ID: <20170717144712.GF3519177@devbig577.frc2.facebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-4-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170716022315.19892-4-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

On Sat, Jul 15, 2017 at 10:23:08PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> Percpu memory holds a minimum threshold of pages that are populated
> in order to serve atomic percpu memory requests. This change makes it
> easier to verify that there are a minimum number of populated pages
> lying around.
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
