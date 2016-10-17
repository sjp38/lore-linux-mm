Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF4646B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 10:12:48 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id g68so32559482ybi.1
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 07:12:48 -0700 (PDT)
Received: from mail-qk0-f196.google.com (mail-qk0-f196.google.com. [209.85.220.196])
        by mx.google.com with ESMTPS id u63si8417260ybf.321.2016.10.17.07.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 07:12:47 -0700 (PDT)
Received: by mail-qk0-f196.google.com with SMTP id n189so14207980qke.1
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 07:12:47 -0700 (PDT)
Date: Mon, 17 Oct 2016 16:12:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] shmem: avoid huge pages for small files
Message-ID: <20161017141245.GC27459@dhcp22.suse.cz>
References: <20161017121809.189039-1-kirill.shutemov@linux.intel.com>
 <20161017123021.rlyz44dsf4l4xnve@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161017123021.rlyz44dsf4l4xnve@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 17-10-16 15:30:21, Kirill A. Shutemov wrote:
[...]
> >From fd0b01b9797ddf2bef308c506c42d3dd50f11793 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Mon, 17 Oct 2016 14:44:47 +0300
> Subject: [PATCH] shmem: avoid huge pages for small files
> 
> Huge pages are detrimental for small file: they causes noticible
> overhead on both allocation performance and memory footprint.
> 
> This patch aimed to address this issue by avoiding huge pages until file
> grown to specified size. This would cover most of the cases where huge
> pages causes regressions in performance.
> 
> By default the minimal file size to allocate huge pages is equal to size
> of huge page.

ok

> We add two handle to specify minimal file size for huge pages:
> 
>   - mount option 'huge_min_size';
> 
>   - sysfs file /sys/kernel/mm/transparent_hugepage/shmem_min_size for
>     in-kernel tmpfs mountpoint;

Could you explain who might like to change the minimum value (other than
disable the feautre for the mount point) and for what reason?

[...]

> @@ -238,6 +238,12 @@ values:
>    - "force":
>      Force the huge option on for all - very useful for testing;
>  
> +Tehre's limit on minimal file size before kenrel starts allocate huge
> +pages for it. By default it's size of huge page.

Smoe tyopse
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
