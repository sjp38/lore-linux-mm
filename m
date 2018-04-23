Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3ECC6B0003
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:04:46 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f23-v6so14733113wra.20
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:04:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h1si63455ede.397.2018.04.23.08.04.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Apr 2018 08:04:43 -0700 (PDT)
Date: Mon, 23 Apr 2018 09:04:35 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v2 PATCH] mm: shmem: make stat.st_blksize return huge page
 size if THP is on
Message-ID: <20180423150435.GS17484@dhcp22.suse.cz>
References: <1524242039-64997-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180423004748.GP17484@dhcp22.suse.cz>
 <3c59a1d1-dc66-ae5f-452c-dd0adb047433@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3c59a1d1-dc66-ae5f-452c-dd0adb047433@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com, Yang Shi <yang.shi@linux.alibaba.com>
Cc: hughd@google.com, hch@infradead.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 22-04-18 21:28:59, Yang Shi wrote:
> 
> 
> On 4/22/18 6:47 PM, Michal Hocko wrote:
[...]
> > will be used on the first aligned address even when the initial/last
> > portion of the mapping is not THP aligned.
> 
> No, my test shows it is not. And, transhuge_vma_suitable() does check the
> virtual address alignment. If it is not huge page size aligned, it will not
> set PMD for huge page.

It's been quite some time since I've looked at that code but I think you
are wrong. It just doesn't make sense to make the THP decision on the
VMA alignment much. Kirill, can you clarify please?

Please note that I have no objections to actually export the huge page
size as the max block size but your changelog just doesn't make any
sense to me.
-- 
Michal Hocko
SUSE Labs
