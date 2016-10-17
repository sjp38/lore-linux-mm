Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 70C5D6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:30:25 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id kc8so200241429pab.2
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 05:30:25 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s123si27239965pgc.243.2016.10.17.05.30.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 05:30:24 -0700 (PDT)
Date: Mon, 17 Oct 2016 15:30:21 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] shmem: avoid huge pages for small files
Message-ID: <20161017123021.rlyz44dsf4l4xnve@black.fi.intel.com>
References: <20161017121809.189039-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161017121809.189039-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 17, 2016 at 03:18:09PM +0300, Kirill A. Shutemov wrote:
> diff --git a/mm/shmem.c b/mm/shmem.c
> index ad7813d73ea7..c69047386e2f 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -369,6 +369,7 @@ static bool shmem_confirm_swap(struct address_space *mapping,
>  /* ifdef here to avoid bloating shmem.o when not necessary */
>  
>  int shmem_huge __read_mostly;
> +unsigned long long shmem_huge_min_size = HPAGE_PMD_SIZE __read_mostly;

Arghh.. Last second changes...

This should be 

unsigned long long shmem_huge_min_size __read_mostly = HPAGE_PMD_SIZE;
