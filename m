Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id A68E16B014E
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 07:33:37 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so2808763wgh.28
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 04:33:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bs19si21487484wib.12.2014.06.11.04.33.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 04:33:35 -0700 (PDT)
Message-ID: <53983E8C.80207@suse.cz>
Date: Wed, 11 Jun 2014 13:33:32 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 05/10] mm, compaction: remember position within pageblock
 in free pages scanner
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz> <1402305982-6928-5-git-send-email-vbabka@suse.cz> <20140611021213.GF15630@bbox>
In-Reply-To: <20140611021213.GF15630@bbox>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/11/2014 04:12 AM, Minchan Kim wrote:
>> >@@ -314,6 +315,9 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>> >  		int isolated, i;
>> >  		struct page *page = cursor;
>> >
>> >+		/* Record how far we have got within the block */
>> >+		*start_pfn = blockpfn;
>> >+
> Couldn't we move this out of the loop for just one store?

You mean using a local variable inside the loop, and assigning once, for 
performance reasons (register vs memory access)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
