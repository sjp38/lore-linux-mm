Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id CBC9C6B0263
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 17:41:13 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id tz10so56340086pab.3
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 14:41:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t188si7695584pgc.18.2016.10.12.14.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 14:41:13 -0700 (PDT)
Date: Wed, 12 Oct 2016 14:41:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v2 PATCH] mm/percpu.c: fix panic triggered by BUG_ON()
 falsely
Message-Id: <20161012144112.0494082cf4cbd07609d2405d@linux-foundation.org>
In-Reply-To: <57FCF07C.2020103@zoho.com>
References: <57FCF07C.2020103@zoho.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, cl@linux.com

On Tue, 11 Oct 2016 22:00:28 +0800 zijun_hu <zijun_hu@zoho.com> wrote:

> as shown by pcpu_build_alloc_info(), the number of units within a percpu
> group is educed by rounding up the number of CPUs within the group to
> @upa boundary, therefore, the number of CPUs isn't equal to the units's
> if it isn't aligned to @upa normally. however, pcpu_page_first_chunk()
> uses BUG_ON() to assert one number is equal the other roughly, so a panic
> is maybe triggered by the BUG_ON() falsely.
> 
> in order to fix this issue, the number of CPUs is rounded up then compared
> with units's, the BUG_ON() is replaced by warning and returning error code
> as well to keep system alive as much as possible.

Under what circumstances is the triggered?  In other words, what are
the end-user visible effects of the fix?

I mean, this is pretty old code (isn't it?) so what are you doing that
triggers this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
