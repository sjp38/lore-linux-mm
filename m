Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id EB3146B006E
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 10:22:29 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id em10so22343073wid.1
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 07:22:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id br7si6640369wjb.140.2015.01.22.07.22.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 Jan 2015 07:22:26 -0800 (PST)
Message-ID: <54C115AC.9030606@suse.cz>
Date: Thu, 22 Jan 2015 16:22:20 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] mm, compaction: encapsulate resetting cached scanner
 positions
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz> <1421661920-4114-4-git-send-email-vbabka@suse.cz> <54BE5885.7030506@gmail.com>
In-Reply-To: <54BE5885.7030506@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On 01/20/2015 02:30 PM, Zhang Yanfei wrote:
> a?? 2015/1/19 18:05, Vlastimil Babka a??e??:
>> Reseting the cached compaction scanner positions is now done implicitly in
>> __reset_isolation_suitable() and compact_finished(). Encapsulate the
>> functionality in a new function reset_cached_positions() and call it
>> explicitly where needed.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Thanks.

> Should the new function be inline?

I'll try comparing with bloat-o-meter before next submission, if there's 
any difference.

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
