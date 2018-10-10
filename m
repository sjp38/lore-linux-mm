Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55B366B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 18:26:59 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 25-v6so2732818pfs.5
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 15:26:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c184-v6si27498372pfg.215.2018.10.10.15.26.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 15:26:58 -0700 (PDT)
Date: Wed, 10 Oct 2018 15:26:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/6] mm/gup_benchmark: Time put_page
Message-Id: <20181010152655.8510270e5db753f6666f12d3@linux-foundation.org>
In-Reply-To: <20181010195605.10689-1-keith.busch@intel.com>
References: <20181010195605.10689-1-keith.busch@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, 10 Oct 2018 13:56:00 -0600 Keith Busch <keith.busch@intel.com> wrote:

> We'd like to measure time to unpin user pages, so this adds a second
> benchmark timer on put_page, separate from get_page.
> 
> Adding the field will breaks this ioctl ABI, but should be okay since
> this an in-tree kernel selftest.
> 
> ...
>
> --- a/mm/gup_benchmark.c
> +++ b/mm/gup_benchmark.c
> @@ -8,7 +8,8 @@
>  #define GUP_FAST_BENCHMARK	_IOWR('g', 1, struct gup_benchmark)
>  
>  struct gup_benchmark {
> -	__u64 delta_usec;
> +	__u64 get_delta_usec;
> +	__u64 put_delta_usec;
>  	__u64 addr;
>  	__u64 size;
>  	__u32 nr_pages_per_call;

If we move put_delta_usec to the end of this struct, the ABI remains
back-compatible?
