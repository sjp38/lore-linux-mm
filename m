Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 18B6E6B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 06:19:48 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so390118pad.29
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 03:19:47 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id n9si1311084pdp.200.2014.11.25.03.19.45
        for <linux-mm@kvack.org>;
        Tue, 25 Nov 2014 03:19:46 -0800 (PST)
Message-ID: <547465d2.0937460a.7739.fffff2baSMTPIN_ADDED_BROKEN@mx.google.com>
From: "Chanho Min" <chanho.min@lge.com>
References: <1416898318-17409-1-git-send-email-chanho.min@lge.com> <20141124230502.30f9b6f0.akpm@linux-foundation.org>
In-Reply-To: <20141124230502.30f9b6f0.akpm@linux-foundation.org>
Subject: RE: [PATCH] mm: add parameter to disable faultaround
Date: Tue, 25 Nov 2014 20:19:40 +0900
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrew Morton' <akpm@linux-foundation.org>
Cc: "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Hugh Dickins' <hughd@google.com>, 'Michal Hocko' <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'HyoJun Im' <hyojun.im@lge.com>, 'Gunho Lee' <gunho.lee@lge.com>, 'Wonhong Kwon' <wonhong.kwon@lge.com>

> > The faultaround improves the file read performance, whereas pages which
> > can be dropped by drop_caches are reduced. On some systems, The amount of
> > freeable pages under memory pressure is more important than read
> > performance.
> 
> The faultaround pages *are* freeable.  Perhaps you meant "free" here.
> 
> Please tell us a great deal about the problem which you are trying to
> solve.  What sort of system, what sort of workload, what is bad about
> the behaviour which you are observing, etc.

We are trying to solve two issues.

We drop page caches by writing to /proc/sys/vm/drop_caches at specific point
and make suspend-to-disk image. The size of this image is increased if faultaround
is worked.

Under memory pressure, we want to drop many page caches as possible.
But, The number of dropped pages are reduced compared to non-faultaround kernel.

Thanks
Chanho,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
