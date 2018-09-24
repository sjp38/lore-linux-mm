Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D13D8E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 12:48:18 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id v16-v6so9016738ybm.2
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 09:48:18 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id s19-v6si3717474ybs.312.2018.09.24.09.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 09:48:17 -0700 (PDT)
Subject: Re: [PATCH] mm/hugetlb: Add mmap() encodings for 32MB and 512MB page
 sizes
References: <1537797985-2406-1-git-send-email-anshuman.khandual@arm.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <541d31f2-b4b7-e401-2fe9-7965d81b2f0a@oracle.com>
Date: Mon, 24 Sep 2018 09:48:05 -0700
MIME-Version: 1.0
In-Reply-To: <1537797985-2406-1-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@kernel.org, punit.agrawal@arm.com, will.deacon@arm.com, akpm@linux-foundation.org

On 9/24/18 7:06 AM, Anshuman Khandual wrote:
> ARM64 architecture also supports 32MB and 512MB HugeTLB page sizes.
> This just adds mmap() system call argument encoding for them.
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  include/uapi/asm-generic/hugetlb_encode.h | 2 ++
>  include/uapi/linux/mman.h                 | 2 ++
>  2 files changed, 4 insertions(+)

Thanks Anshuman,

However, I think we should also add similar definitions in:
uapi/linux/memfd.h
uapi/linux/shm.h

-- 
Mike Kravetz
