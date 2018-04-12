Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 922666B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 23:26:26 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f9-v6so2710142plo.17
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 20:26:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k193sor593015pgc.86.2018.04.11.20.26.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Apr 2018 20:26:25 -0700 (PDT)
Date: Thu, 12 Apr 2018 11:26:16 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/2] mm/sparse: pass the __highest_present_section_nr + 1
 to alloc_func()
Message-ID: <20180412032616.GA56479@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180326081956.75275-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180326081956.75275-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dave.hansen@linux.intel.com, Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org

Hi, Andrew

I saw you merged one related patch recently, not sure you would take these two?

On Mon, Mar 26, 2018 at 04:19:55PM +0800, Wei Yang wrote:
>In 'commit c4e1be9ec113 ("mm, sparsemem: break out of loops early")',
>__highest_present_section_nr is introduced to reduce the loop counts for
>present section. This is also helpful for usemap and memmap allocation.
>
>This patch uses __highest_present_section_nr + 1 to optimize the loop.
>
>Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>---
> mm/sparse.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/mm/sparse.c b/mm/sparse.c
>index 7af5e7a92528..505050346249 100644
>--- a/mm/sparse.c
>+++ b/mm/sparse.c
>@@ -561,7 +561,7 @@ static void __init alloc_usemap_and_memmap(void (*alloc_func)
> 		map_count = 1;
> 	}
> 	/* ok, last chunk */
>-	alloc_func(data, pnum_begin, NR_MEM_SECTIONS,
>+	alloc_func(data, pnum_begin, __highest_present_section_nr+1,
> 						map_count, nodeid_begin);
> }
> 
>-- 
>2.15.1

-- 
Wei Yang
Help you, Help me
