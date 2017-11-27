Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B76AD6B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:46:10 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id t92so19363285wrc.13
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 11:46:10 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y19sor6865196wrg.81.2017.11.27.11.46.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 11:46:09 -0800 (PST)
Date: Mon, 27 Nov 2017 22:46:03 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] mm: disable `vm.max_map_count' sysctl limit
Message-ID: <20171127194603.GA28115@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mikpelinux.gmail.com@avx2.kvack.org
Cc: linux-kernel@vger.kernel.org, mhocko@kernel.org, willy@infradead.org, ak@linux.intel.com, linux-mm@kvack.org

> vm.max_map_count

I always thought it is some kind of algorithmic complexity limiter and
kernel memory limiter. VMAs are under SLAB_ACCOUNT nowadays but ->mmap
list stays:

	$ chgrep -e 'for.*vma = vma->vm_next' | wc -l
	41

In particular readdir on /proc/*/map_files .

I'm saying you can not simply remove this sysctl.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
