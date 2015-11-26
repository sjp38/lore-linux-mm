Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8693B6B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 05:43:59 -0500 (EST)
Received: by wmvv187 with SMTP id v187so25105774wmv.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 02:43:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b8si40547841wjx.62.2015.11.26.02.43.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Nov 2015 02:43:58 -0800 (PST)
Subject: Re: [PATCH v2 7/9] mm, page_owner: dump page owner info from
 dump_page()
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-8-git-send-email-vbabka@suse.cz>
 <20151125145853.GM27283@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5656E26D.1070503@suse.cz>
Date: Thu, 26 Nov 2015 11:43:57 +0100
MIME-Version: 1.0
In-Reply-To: <20151125145853.GM27283@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On 11/25/2015 03:58 PM, Michal Hocko wrote:
> Nice! This can be really helpful.
> 
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Appart from a typo below, looks good to me
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> [...]
> 
>> +void __dump_page_owner(struct page *page)
>> +{
>> +	struct page_ext *page_ext = lookup_page_ext(page);
>> +	struct stack_trace trace = {
>> +		.nr_entries = page_ext->nr_entries,
>> +		.entries = &page_ext->trace_entries[0],
>> +	};
>> +	gfp_t gfp_mask = page_ext->gfp_mask;
>> +	int mt = gfpflags_to_migratetype(gfp_mask);
>> +
>> +	if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags)) {
>> +		pr_alert("page_owner info is not active (free page?)\n");
>> +		return;
>> +	}
>> +			                        ;
> 
> Typo?

The cat did it!

------8<------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 26 Nov 2015 11:41:11 +0100
Subject: mm, page_owner: dump page owner info from dump_page()-fix

Remove stray semicolon.
---
 mm/page_owner.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index a81cfa0c13c3..f4acd2452c35 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -207,7 +207,7 @@ void __dump_page_owner(struct page *page)
 		pr_alert("page_owner info is not active (free page?)\n");
 		return;
 	}
-			                        ;
+
 	pr_alert("page allocated via order %u, migratetype %s, gfp_mask 0x%x",
 			page_ext->order, migratetype_names[mt], gfp_mask);
 	dump_gfpflag_names(gfp_mask);
-- 
2.6.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
