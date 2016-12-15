Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D2EC6B0069
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 11:47:30 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id j10so25182555wjb.3
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 08:47:30 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id s206si13438708wmf.158.2016.12.15.08.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 08:47:29 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id g23so7643969wme.1
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 08:47:28 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] mm, slab: consolidate KMALLOC_MAX_SIZE
Date: Thu, 15 Dec 2016 17:47:20 +0100
Message-Id: <20161215164722.21586-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Cristopher Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Alexei Starovoitov <ast@kernel.org>, Andrey Konovalov <andreyknvl@google.com>, Michal Hocko <mhocko@suse.com>

Hi,
Andrey has revealed a discrepancy between KMALLOC_MAX_SIZE and the
maximum supported page allocator size [1]. The underlying problem
should be fixed in the ep_write_iter code of course, but I do not feel
qualified to do that. The discrepancy which it reveals (see patch 2)
is worth fixing anyway, though.

While I was looking into the code, I've noticed that the only code which
uses KMALLOC_SHIFT_MAX outside of the slab code is bpf so I've updated
it to use KMALLOC_MAX_SIZE instead. There shouldn't be any real reason
to use KMALLOC_SHIFT_MAX which is a slab internal constant same as
KMALLOC_SHIFT_{LOW,HIGH}

[1] http://lkml.kernel.org/r/CAAeHK+ztusS68DejO8AH3nn-EfiYQpD5FmBwmqKG8BWvoqPNqQ@mail.gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
