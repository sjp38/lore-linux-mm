Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0685A6B026D
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 09:42:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id v19-v6so5763827eds.3
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 06:42:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h11-v6si32509edj.452.2018.07.02.06.42.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 06:42:28 -0700 (PDT)
Date: Mon, 2 Jul 2018 15:42:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v3 PATCH 3/5] mm: refactor do_munmap() to extract the
 common part
Message-ID: <20180702134226.GX19043@dhcp22.suse.cz>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-4-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530311985-31251-4-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Sat 30-06-18 06:39:43, Yang Shi wrote:
> Introduces two new helper functions:
>   * munmap_addr_sanity()
>   * munmap_lookup_vma()
> 
> They will be used by do_munmap() and the new do_munmap with zapping
> large mapping early in the later patch.
> 
> There is no functional change, just code refactor.

There are whitespace changes which make the code much harder to review
than necessary.
> +static inline bool munmap_addr_sanity(unsigned long start, size_t len)
>  {
> -	unsigned long end;
> -	struct vm_area_struct *vma, *prev, *last;
> +	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE - start)
> +		return false;
>  
> -	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE-start)
> -		return -EINVAL;

e.g. here.
-- 
Michal Hocko
SUSE Labs
