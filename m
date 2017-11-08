Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CCFF64403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 02:47:55 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id s75so1804902pgs.12
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 23:47:55 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f2si3226211plk.121.2017.11.07.23.47.54
        for <linux-mm@kvack.org>;
        Tue, 07 Nov 2017 23:47:54 -0800 (PST)
Date: Wed, 8 Nov 2017 16:52:42 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm: page_ext: allocate page extension though first PFN
 is invalid
Message-ID: <20171108075242.GB18747@js1304-P5Q-DELUXE>
References: <CGME20171107094311epcas1p4a5dd975d6e9f3618a26a0a5d68c68b55@epcas1p4.samsung.com>
 <20171107094447.14763-1-jaewon31.kim@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171107094447.14763-1-jaewon31.kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On Tue, Nov 07, 2017 at 06:44:47PM +0900, Jaewon Kim wrote:
> online_page_ext and page_ext_init allocate page_ext for each section, but
> they do not allocate if the first PFN is !pfn_present(pfn) or
> !pfn_valid(pfn).
> 
> Though the first page is not valid, page_ext could be useful for other
> pages in the section. But checking all PFNs in a section may be time
> consuming job. Let's check each (section count / 16) PFN, then prepare
> page_ext if any PFN is present or valid.

I guess that this kind of section is not so many. And, this is for
debugging so completeness would be important. It's better to check
all pfn in the section.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
