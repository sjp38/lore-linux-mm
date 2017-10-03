Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id EBBA66B0033
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 17:05:44 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id a11so1335044qti.20
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 14:05:44 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b200sor6004176itc.42.2017.10.03.14.05.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Oct 2017 14:05:44 -0700 (PDT)
Date: Tue, 3 Oct 2017 14:05:40 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm/percpu.c: use smarter memory allocation for struct
 pcpu_alloc_info
Message-ID: <20171003210540.GM3301751@devbig577.frc2.facebook.com>
References: <nycvar.YSQ.7.76.1710031638450.5407@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1710031638450.5407@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 03, 2017 at 04:57:44PM -0400, Nicolas Pitre wrote:
> This can be much smaller than a page on very small memory systems. 
> Always rounding up the size to a page is wasteful in that case, and 
> required alignment is smaller than the memblock default. Let's round 
> things up to a page size only when the actual size is >= page size, and 
> then it makes sense to page-align for a nicer allocation pattern.

Isn't that a temporary area which gets freed later during boot?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
