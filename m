Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 171346B0268
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 16:57:31 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b2so7614306pgt.6
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 13:57:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g1-v6si8906271plt.54.2018.03.30.13.57.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Mar 2018 13:57:29 -0700 (PDT)
Date: Fri, 30 Mar 2018 13:57:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memblock: fix potential issue in
 memblock_search_pfn_nid()
Message-Id: <20180330135727.67251c7ea8c2db28b404e0e1@linux-foundation.org>
In-Reply-To: <20180330033055.22340-1-richard.weiyang@gmail.com>
References: <20180330033055.22340-1-richard.weiyang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, yinghai@kernel.org, linux-mm@kvack.org, hejianet@gmail.com, "3 . 12+" <stable@vger.kernel.org>

On Fri, 30 Mar 2018 11:30:55 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:

> memblock_search_pfn_nid() returns the nid and the [start|end]_pfn of the
> memory region where pfn sits in. While the calculation of start_pfn has
> potential issue when the regions base is not page aligned.
> 
> For example, we assume PAGE_SHIFT is 12 and base is 0x1234. Current
> implementation would return 1 while this is not correct.

Why is this not correct?  The caller might want the pfn of the page
which covers the base?

> This patch fixes this by using PFN_UP().
> 
> The original commit is commit e76b63f80d93 ("memblock, numa: binary search
> node id") and merged in v3.12.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> Cc: 3.12+ <stable@vger.kernel.org>

Please fully describe the runtime effects of a bug when fixing that
bug.  This description doesn't give enough justification for merging
the patch into mainline, let alone -stable.
