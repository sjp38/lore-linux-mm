Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 133146B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 09:45:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x125so142250742pgb.5
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 06:45:32 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0093.outbound.protection.outlook.com. [104.47.2.93])
        by mx.google.com with ESMTPS id n8si14327339pgd.294.2017.04.03.06.45.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 06:45:31 -0700 (PDT)
Subject: Re: [PATCH] mm/zswap: fix potential deadlock in
 zswap_frontswap_store()
References: <20170331153009.11397-1-aryabinin@virtuozzo.com>
 <CALvZod5rnV5ZjKYxFwPDX8NcRQKJfwN-iWyVD-Mm4+fKten1+A@mail.gmail.com>
 <20170403084729.GG24661@dhcp22.suse.cz>
 <c4e8b895-260c-9b47-4531-5fac5cefa77c@virtuozzo.com>
 <eea593fd-c59d-cad0-936b-c012df1abadd@virtuozzo.com>
 <28e47653-96d7-288a-0c9b-e065b29d7c45@suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <8f29ec95-50a8-c776-30dc-e79e6b0d7349@virtuozzo.com>
Date: Mon, 3 Apr 2017 16:46:52 +0300
MIME-Version: 1.0
In-Reply-To: <28e47653-96d7-288a-0c9b-e065b29d7c45@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 04/03/2017 04:28 PM, Vlastimil Babka wrote:

>>
>>
>> Seems it was broken by
>>
>> a8161d1ed6098506303c65b3701dedba876df42a
>> Author: Vlastimil Babka <vbabka@suse.cz>
>> Date:   Thu Jul 28 15:49:19 2016 -0700
>>
>>     mm, page_alloc: restructure direct compaction handling in slowpath
> 
> Yeah, looks like previously the code subtly relied on compaction being
> called only after the PF_MEMALLOC -> goto nopage check and I didn't
> notice it. Tell me if I should add a check or you plan to send a patch.
> Thanks!

I would be glad if you could take care of this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
